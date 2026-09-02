import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel", "button"];

  toggle() {
    const expanded = !this.panelTarget.classList.toggle("hidden");
    this.buttonTarget.setAttribute("aria-expanded", String(expanded));
  }
}
