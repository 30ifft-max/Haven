import { Controller } from "@hotwired/stimulus"

// Keeps the category list focused: expanding a parent closes the other
// parents, while native <details> preserves keyboard and screen-reader support.
export default class extends Controller {
  static targets = ["item"]

  toggle(event) {
    const openedItem = event.currentTarget
    if (!openedItem.open) return

    this.itemTargets.forEach((item) => {
      if (item !== openedItem) item.open = false
    })
  }
}
