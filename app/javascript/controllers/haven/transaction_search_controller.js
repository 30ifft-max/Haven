import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.desktop = window.matchMedia("(min-width: 768px)");
    this.resize = () => {
      this.element.open = this.desktop.matches || !!this.input.value;
    };
    this.outsideClick = (event) => {
      if (!this.desktop.matches && !this.element.contains(event.target) && !this.input.value) {
        this.element.open = false;
      }
    };
    this.desktop.addEventListener("change", this.resize);
    document.addEventListener("click", this.outsideClick);
    this.resize();
  }

  disconnect() {
    this.desktop.removeEventListener("change", this.resize);
    document.removeEventListener("click", this.outsideClick);
  }

  get input() {
    return this.element.querySelector('input[name="q[search]"]');
  }
}
