import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["empty", "selected", "searchInput"];
  static values = { removeLabel: String };

  connect() {
    this.updateSelected();
  }

  updateSelected() {
    const inputs = this.selectedInputs();
    this.emptyTarget.hidden = inputs.length > 0;
    this.selectedTarget.replaceChildren(...inputs.map((input) => this.selectedItem(input)));
  }

  focusSearch(event) {
    const filterId = event.target.closest("button")?.dataset.id;
    if (!["account_filter", "category_filter", "tag_filter", "merchant_filter"].includes(filterId)) return;

    window.requestAnimationFrame(() => {
      window.requestAnimationFrame(() => this.activeSearchInput()?.focus());
    });
  }

  removeSelected(event) {
    const input = this.element.querySelector(`#${CSS.escape(event.currentTarget.dataset.inputId)}`);
    if (!input) return;

    if (input.type === "checkbox") input.checked = false;
    else input.value = "";

    input.dispatchEvent(new Event("change", { bubbles: true }));
  }

  selectedInputs() {
    return Array.from(this.element.querySelectorAll("input, select")).filter((input) => {
      if (input.type === "hidden" || input.disabled || !input.name.startsWith("q[")) return false;
      if (input.type === "checkbox") return input.checked;
      return input.value;
    });
  }

  activeSearchInput() {
    return this.searchInputTargets.find(
      (input) => input.offsetParent !== null,
    );
  }

  labelFor(input) {
    if (input.tagName === "SELECT") return input.selectedOptions[0]?.textContent.trim();
    const label = input.id && this.element.querySelector(`label[for="${input.id}"]`);
    return label ? label.textContent.trim() : input.value;
  }

  selectedItem(input) {
    const item = document.createElement("div");
    item.className = "flex items-center gap-2 rounded-md bg-container-inset px-3 py-2 text-sm text-primary";

    const label = document.createElement("span");
    label.className = "min-w-0 flex-1 truncate";
    label.textContent = this.labelFor(input);

    const remove = document.createElement("button");
    remove.type = "button";
    remove.className = "text-secondary hover:text-primary";
    remove.setAttribute("aria-label", this.removeLabelValue);
    remove.dataset.action = "click->transaction-filter-menu#removeSelected";
    remove.dataset.inputId = input.id;
    remove.textContent = "×";

    item.append(label, remove);
    return item;
  }
}
