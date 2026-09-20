import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  select() {
    this.element.select();
  }

  format() {
    const digits = this.element.value.replace(/\D/g, "").slice(0, 4);
    this.element.value = digits.length > 2 ? `${digits.slice(0, 2)}:${digits.slice(2)}` : digits;
  }

  normalize() {
    const digits = this.element.value.replace(/\D/g, "");
    if (digits.length === 0) {
      this.element.value = "00:00";
      return;
    }

    const padded = digits.padStart(4, "0").slice(-4);
    const hours = Math.min(Number(padded.slice(0, 2)), 23);
    const minutes = Math.min(Number(padded.slice(2)), 59);
    this.element.value = `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}`;
  }
}
