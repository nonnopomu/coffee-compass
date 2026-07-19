import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton"]
  static values = {
    disabledText: String
  }

  disable(event) {
    const submitter = event.submitter || event.detail?.formSubmission?.submitter
    const buttons = this.hasSubmitButtonTarget ? this.submitButtonTargets : [submitter].filter(Boolean)

    buttons.forEach((button) => {
      if (button.disabled) return

      this.changeButtonText(button)
      button.disabled = true
      button.classList.add("cursor-not-allowed", "opacity-70")
    })
  }

  changeButtonText(button) {
    if (!this.hasDisabledTextValue) return

    if (button.tagName === "INPUT") {
      button.value = this.disabledTextValue
      return
    }

    button.textContent = this.disabledTextValue
  }
}
