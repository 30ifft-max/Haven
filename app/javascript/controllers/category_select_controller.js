import { Controller } from "@hotwired/stimulus";
import { autoUpdate } from "@floating-ui/dom";

const FOCUSABLE_SELECTOR = "a[href], button:not([disabled]), input:not([disabled]):not([type=hidden]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex='-1'])";

export default class extends Controller {
  static targets = [
    "button",
    "menu",
    "search",
    "option",
    "selectionContainer",
    "hiddenInput",
    "createForm",
    "createLabel",
    "createError",
    "menuContent",
  ];

  static values = {
    createUrl: String,
    defaultColor: String,
    disabled: Boolean,
    autoSubmit: Boolean,
    createLabel: String,
    createErrorMessage: String,
    fixedMenu: Boolean,
  };

  connect() {
    this.creating = false;
    this.isOpen = false;
    this.boundOutsideClick = this.handleOutsideClick.bind(this);
    document.addEventListener("click", this.boundOutsideClick);
    this.resizeObserver = new ResizeObserver(() => this.updatePosition());
    this.resizeObserver.observe(this.menuTarget);
  }

  disconnect() {
    document.removeEventListener("click", this.boundOutsideClick);
    this.stopAutoUpdate();
    this.resizeObserver?.disconnect();
  }

  toggle(event) {
    event.preventDefault();
    if (this.disabledValue) return;

    this.isOpen ? this.close() : this.open();
  }

  open() {
    this.isOpen = true;
    this.buttonTarget.setAttribute("aria-expanded", "true");
    this.menuTarget.classList.remove("hidden");
    this.startAutoUpdate();

    this.searchTarget.value = "";
    this.filter();

    requestAnimationFrame(() => {
      this.updatePosition();
      this.searchTarget.focus({ preventScroll: true });
    });
  }

  close() {
    this.isOpen = false;
    this.buttonTarget.setAttribute("aria-expanded", "false");
    this.menuTarget.classList.add("hidden");
    this.stopAutoUpdate();
  }

  filter() {
    this.clearCreateError();

    const rawQuery = this.searchTarget.value.trim();
    const query = rawQuery.toLowerCase();

    let exactMatch = false;

    this.optionTargets.forEach((option) => {
      const name = option.dataset.categoryName.toLowerCase();
      const matches = name.includes(query);

      option.classList.toggle("hidden", !matches);

      if (name === query) exactMatch = true;
    });

    const canCreate = rawQuery.length > 0 && !exactMatch;

    this.createFormTarget.classList.toggle("hidden", !canCreate);
    this.createFormTarget.classList.toggle("flex", canCreate);

    this.createLabelTarget.textContent =
      this.createLabelValue.replace("__CATEGORY_NAME__", rawQuery);
  }

  handleSearchKeydown(event) {
    if (event.key === "Escape") {
      event.preventDefault();
      this.close();
      this.buttonTarget.focus();
      return;
    }

    if (event.key === "Enter") {
      const firstVisibleOption = this.optionTargets.find(
        (option) => !option.classList.contains("hidden"),
      );

      if (firstVisibleOption) {
        event.preventDefault();
        this.selectOption(firstVisibleOption);
        this.close();
        this.submitForm();
      } else if (!this.createFormTarget.classList.contains("hidden") && !this.creating) {
        event.preventDefault();
        this.createCategory();
      }
    }
  }

  handleButtonFocus() {
    if (this.isOpen || !this.buttonTarget.matches(":focus-visible")) return;
    this.open();
  }

  handleButtonKeydown(event) {
    if (["ArrowDown", "ArrowUp", " ", "Enter"].includes(event.key)) {
      event.preventDefault();
      this.open();
    }
  }

  handleMenuKeydown(event) {
    if (event.key !== "Tab") return;
    event.preventDefault();
    const scope = this.element.closest("dialog") || document;
    const focusables = Array.from(scope.querySelectorAll(FOCUSABLE_SELECTOR)).filter((el) =>
      !el.closest("[inert]") && !this.menuTarget.contains(el) && (el.offsetParent !== null || el === document.activeElement)
    );
    const index = focusables.indexOf(this.buttonTarget);
    const next = focusables[index + (event.shiftKey ? -1 : 1)];
    this.close();
    next?.focus();
  }

  selectCategory(event) {
    event.preventDefault();

    const option = event.currentTarget;

    this.selectOption(option);
    this.close();
    this.submitForm();
  }

  selectOption(option) {
    const id = option.dataset.categoryId;

    this.optionTargets.forEach((candidate) => {
      const selected = candidate === option;

      candidate.setAttribute(
        "aria-selected",
        selected ? "true" : "false",
      );

      candidate.classList.toggle("bg-container-inset", selected);

      const checkIcon = candidate.querySelector(".check-icon");
      if (checkIcon) checkIcon.classList.toggle("invisible", !selected);
    });

    this.hiddenInputTarget.value = id;

    const badge = option.querySelector("[data-category-select-badge]");

    this.selectionContainerTarget.innerHTML = "";

    if (badge) {
      this.selectionContainerTarget.appendChild(badge.cloneNode(true));
    } else {
      this.selectionContainerTarget.textContent =
        option.dataset.categoryDisplayLabel;
    }
  }

  async createCategory() {
    if (this.creating) return;

    const name = this.searchTarget.value.trim();
    if (!name) return;

    this.creating = true;
    this.createFormTarget.disabled = true;
    this.clearCreateError();

    try {
      const response = await fetch(this.createUrlValue, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken,
        },
        body: JSON.stringify({
          category: {
            name,
            color: this.defaultColorValue,
          },
        }),
      });

      const category = await response.json();

      if (!response.ok) {
        this.showCreateError(
          category.errors?.join(", ") || category.error,
        );
        return;
      }

      this.createFormTarget.insertAdjacentHTML(
        "beforebegin",
        category.html,
      );

      const newOption = this.optionTargets.find(
        (option) =>
        option.dataset.categoryId === String(category.id),
      );

      if (newOption) this.selectOption(newOption);

      this.searchTarget.value = "";
      this.filter();
      this.close();
      this.submitForm();
    } catch {
      this.showCreateError();
    } finally {
      this.creating = false;
      this.createFormTarget.disabled = false;
    }
  }

  async submitForm() {
    if (!this.autoSubmitValue) return;

    const form = this.element.closest("form");
    if (form) form.requestSubmit();
  }

  handleOutsideClick(event) {
    if (this.isOpen && !this.element.contains(event.target) && !this.menuTarget.contains(event.target)) {
      this.close();
    }
  }

  startAutoUpdate() {
    if (!this.cleanupPosition) {
      this.cleanupPosition = autoUpdate(this.buttonTarget, this.menuTarget, () => this.updatePosition());
    }
  }

  stopAutoUpdate() {
    this.cleanupPosition?.();
    this.cleanupPosition = null;
  }

  updatePosition() {
    if (!this.isOpen || !this.fixedMenuValue) return;
    const rect = this.buttonTarget.getBoundingClientRect();
    const padding = 12;
    const width = Math.min(rect.width, window.innerWidth - padding * 2);
    const below = window.innerHeight - rect.bottom - padding;
    const above = rect.top - padding;
    const fullHeight = this.menuTarget.scrollHeight;
    const openUp = below < fullHeight && above > below;
    const available = Math.max(0, (openUp ? above : below) - 6);

    Object.assign(this.menuTarget.style, {
      position: "fixed",
      left: `${Math.min(Math.max(padding, rect.left), window.innerWidth - width - padding)}px`,
      right: "auto",
      top: openUp ? "auto" : `${rect.bottom + 6}px`,
      bottom: openUp ? `${window.innerHeight - rect.top + 6}px` : "auto",
      width: `${width}px`,
      maxHeight: `${available}px`,
    });
    this.menuContentTarget.style.maxHeight = `${Math.max(0, available - 54)}px`;
  }

  clearCreateError() {
    this.createErrorTarget.textContent = "";
    this.createErrorTarget.classList.add("hidden");
  }

  showCreateError(message) {
    this.createErrorTarget.textContent =
      message || this.createErrorMessageValue;

    this.createErrorTarget.classList.remove("hidden");
  }

  get csrfToken() {
    return document
      .querySelector('meta[name="csrf-token"]')
      ?.getAttribute("content");
  }
}
