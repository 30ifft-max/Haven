import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["startDate", "endDate", "startYear", "startMonth", "startDay", "endYear", "endMonth", "endDay", "quick"];

  connect() {
    this.populateParts("start");
    this.populateParts("end");
    this.refreshQuickState();
  }

  selectQuick(event) {
    const quick = event.currentTarget;
    this.setDate("start", quick.dataset.transactionDateFilterStartValue);
    this.setDate("end", quick.dataset.transactionDateFilterEndValue);
    this.setButtonLabel(quick.dataset.transactionDateFilterLabelValue);
    this.refreshQuickState();
  }

  updateStartDate(event) { this.updateDate("start", event.target); }
  updateEndDate(event) { this.updateDate("end", event.target); }
  adjustStartDate(event) { this.adjustDate("start", event); }
  adjustEndDate(event) { this.adjustDate("end", event); }

  clearStart() { this.clearDate("start"); }
  clearEnd() { this.clearDate("end"); }
  clearAll() { this.clearDate("start"); this.clearDate("end"); }

  updateDate(group, input) {
    const maxLength = input === this.parts(group).year ? 4 : 2;
    input.value = input.value.replace(/\D/g, "").slice(0, maxLength);
    this.clampParts(group);
    this.syncDate(group);
  }

  adjustDate(group, event) {
    if (event.key !== "+" && event.key !== "-") return;
    event.preventDefault();
    const date = this.dateFor(group) || new Date();
    date.setDate(date.getDate() + (event.key === "+" ? 1 : -1));
    this.setDate(group, this.toIsoDate(this.clampDate(date)));
  }

  clearDate(group) {
    const { year, month, day, hidden } = this.parts(group);
    year.value = month.value = day.value = hidden.value = "";
    this.customDateChanged();
  }

  setDate(group, isoDate) {
    const date = this.parseIsoDate(isoDate);
    if (!date) return this.clearDate(group);
    const { year, month, day, hidden } = this.parts(group);
    year.value = date.getFullYear();
    month.value = String(date.getMonth() + 1).padStart(2, "0");
    day.value = String(date.getDate()).padStart(2, "0");
    hidden.value = this.toIsoDate(date);
    this.customDateChanged();
  }

  populateParts(group) {
    if (this.parts(group).hidden.value) this.setDate(group, this.parts(group).hidden.value);
  }

  clampParts(group) {
    const { year, month, day } = this.parts(group);
    if (year.value.length === 4) year.value = String(Math.min(2100, Math.max(1990, Number(year.value))));
    if (month.value.length === 2) month.value = String(Math.min(12, Math.max(1, Number(month.value)))).padStart(2, "0");
    if (day.value.length === 2) day.value = String(Math.min(31, Math.max(1, Number(day.value)))).padStart(2, "0");
    if (year.value.length === 4 && month.value.length === 2 && day.value.length === 2) {
      const lastDay = new Date(Number(year.value), Number(month.value), 0).getDate();
      day.value = String(Math.min(lastDay, Number(day.value))).padStart(2, "0");
    }
  }

  syncDate(group) {
    const date = this.dateFor(group);
    this.parts(group).hidden.value = date ? this.toIsoDate(date) : "";
    this.ensureChronologicalRange(group);
    this.customDateChanged();
  }

  ensureChronologicalRange(changedGroup) {
    const startDate = this.startDateTarget.value;
    const endDate = this.endDateTarget.value;
    if (!startDate || !endDate || startDate <= endDate) return;

    const otherGroup = changedGroup === "start" ? "end" : "start";
    this.setDate(otherGroup, this.parts(changedGroup).hidden.value);
  }

  dateFor(group) {
    const { year, month, day } = this.parts(group);
    if (year.value.length !== 4 || month.value.length !== 2 || day.value.length !== 2) return null;
    const date = new Date(Number(year.value), Number(month.value) - 1, Number(day.value));
    return date.getFullYear() === Number(year.value) && date.getMonth() === Number(month.value) - 1 && date.getDate() === Number(day.value) ? date : null;
  }

  clampDate(date) {
    const min = new Date(1990, 0, 1);
    const max = new Date(2100, 11, 31);
    return date < min ? min : date > max ? max : date;
  }

  customDateChanged() {
    const matchingQuick = this.quickTargets.find((quick) => quick.dataset.transactionDateFilterStartValue === this.startDateTarget.value && quick.dataset.transactionDateFilterEndValue === this.endDateTarget.value);
    this.setButtonLabel(matchingQuick ? matchingQuick.dataset.transactionDateFilterLabelValue : this.button.dataset.defaultLabel);
    this.refreshQuickState();
  }

  refreshQuickState() {
    this.quickTargets.forEach((quick) => {
      const active = quick.dataset.transactionDateFilterStartValue === this.startDateTarget.value && quick.dataset.transactionDateFilterEndValue === this.endDateTarget.value;
      quick.classList.toggle("bg-container-inset", active);
      quick.classList.toggle("text-primary", active);
      quick.classList.toggle("text-secondary", !active);
    });
  }

  parseIsoDate(value) {
    const match = value.match(/^(\d{4})-(\d{2})-(\d{2})$/);
    return match ? this.clampDate(new Date(Number(match[1]), Number(match[2]) - 1, Number(match[3]))) : null;
  }

  toIsoDate(date) { return [date.getFullYear(), String(date.getMonth() + 1).padStart(2, "0"), String(date.getDate()).padStart(2, "0")].join("-"); }
  setButtonLabel(label) { const text = this.button.querySelector("span"); if (text) text.textContent = label; }
  get button() { return document.getElementById("transaction-date-button"); }

  parts(group) {
    return {
      year: this[`${group}YearTarget`], month: this[`${group}MonthTarget`], day: this[`${group}DayTarget`], hidden: this[`${group}DateTarget`],
    };
  }
}
