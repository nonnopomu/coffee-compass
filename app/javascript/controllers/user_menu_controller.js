import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "menu"]

  toggle(event) {
    event.stopPropagation()

    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  closeOnOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  close() {
    this.menuTarget.classList.add("hidden")
    this.buttonTarget.classList.remove("ring-2", "ring-amber-300", "ring-offset-2")
  }

  open() {
    this.menuTarget.classList.remove("hidden")
    this.buttonTarget.classList.add("ring-2", "ring-amber-300", "ring-offset-2")
  }
}
