import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "children", "chevron"]

  toggle() {
    const expanded = this.buttonTarget.getAttribute("aria-expanded") === "true"
    this.childrenTarget.classList.toggle("grid-rows-[1fr]", !expanded)
    this.childrenTarget.classList.toggle("grid-rows-[0fr]", expanded)
    this.chevronTarget.classList.toggle("rotate-180", !expanded)
    this.buttonTarget.setAttribute("aria-expanded", String(!expanded))
  }
}
