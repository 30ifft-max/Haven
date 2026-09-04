import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["operator", "panel"];

  connect() {
    this.toggle();
  }

  toggle(event) {
    const changedOperator = event?.currentTarget;
    if (changedOperator?.checked) {
      this.operatorTargets.forEach((operator) => {
        if (operator !== changedOperator) operator.checked = false;
      });
    }

    const operator = this.selectedOperator;
    this.panelTargets.forEach((panel) => {
      const active = panel.dataset.operator === operator;
      panel.classList.toggle("hidden", !active);
      panel.querySelectorAll("input").forEach((input) => {
        input.disabled = !active;
      });
    });
  }

  get selectedOperator() {
    return this.operatorTargets.find((operator) => operator.checked)?.value;
  }
}
