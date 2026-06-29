import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open(event) {
    if (event.type === "keydown" && !["Enter", " "].includes(event.key)) return
    if (event.type === "keydown") event.preventDefault()

    this.element.focus()

    if (typeof this.element.showPicker !== "function") return

    try {
      this.element.showPicker()
    } catch (_error) {
      // Some browsers only allow showPicker during direct user interaction.
    }
  }
}
