import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["enabled", "select"];

  toggle() {
    this.selectTarget.disabled = !this.enabledTarget.checked;
    if (this.enabledTarget.checked && !this.selectTarget.value) {
      this.selectTarget.selectedIndex = 0;
    }
  }
}
