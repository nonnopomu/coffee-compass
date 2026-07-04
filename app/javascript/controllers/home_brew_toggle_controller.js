import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mode",
    "cafeFields",
    "cafeValue",
    "query",
    "selected",
    "results",
    "message",
    "option",
    "cafeImageHelp",
    "homeImageHelp"
  ]

  connect() {
    this.update()
  }

  toggle() {
    this.update()
  }

  update() {
    const brewedAtHome = this.modeTargets.some((mode) => mode.checked && mode.value === "1")

    this.cafeFieldsTarget.classList.toggle("hidden", brewedAtHome)
    this.cafeValueTarget.disabled = brewedAtHome
    this.queryTarget.disabled = brewedAtHome
    this.toggleImageHelp(brewedAtHome)

    if (brewedAtHome) {
      this.clearCafeSelection()
    }
  }

  clearCafeSelection() {
    this.cafeValueTarget.value = ""
    this.queryTarget.value = ""
    this.selectedTarget.classList.add("hidden")
    this.resultsTarget.classList.add("hidden")
    this.messageTarget.classList.add("hidden")
    this.optionTargets.forEach((option) => option.classList.add("hidden"))
  }

  toggleImageHelp(brewedAtHome) {
    if (!this.hasCafeImageHelpTarget || !this.hasHomeImageHelpTarget) return

    this.cafeImageHelpTarget.classList.toggle("hidden", brewedAtHome)
    this.homeImageHelpTarget.classList.toggle("hidden", !brewedAtHome)
  }
}
