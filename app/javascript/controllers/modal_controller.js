import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
    document.body.classList.remove("overflow-hidden")
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    this.displayClasses.forEach(className => this.panelTarget.classList.add(className))
    document.body.classList.add("overflow-hidden")
  }

  close() {
    this.displayClasses.forEach(className => this.panelTarget.classList.remove(className))
    this.panelTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }

  closeOnBackdrop(event) {
    if (event.target === this.panelTarget) {
      this.close()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape" && !this.panelTarget.classList.contains("hidden")) {
      this.close()
    }
  }

  get displayClasses() {
    return (this.panelTarget.dataset.modalDisplayClass || "").split(" ").filter(Boolean)
  }
}
