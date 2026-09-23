import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { defaultToday: Boolean };

  connect() {
    const today = this.localDate();
    this.element.max = today;

    if (this.defaultTodayValue && !this.element.value) {
      this.element.value = today;
    }
  }

  localDate() {
    const now = new Date();
    const month = String(now.getMonth() + 1).padStart(2, "0");
    const day = String(now.getDate()).padStart(2, "0");
    return `${now.getFullYear()}-${month}-${day}`;
  }
}
