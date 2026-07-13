import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "keyword", "chips", "empty"]
  static values = { keywordLabelPrefix: String }

  connect() {
    this.update()
  }

  update() {
    const conditions = this.selectedConditions()

    this.chipsTarget.replaceChildren()
    conditions.forEach(condition => this.chipsTarget.appendChild(this.buildChip(condition)))

    if (this.hasEmptyTarget) {
      this.emptyTarget.classList.toggle("hidden", conditions.length > 0)
    }
  }

  remove(event) {
    const conditionType = event.currentTarget.dataset.conditionType
    const conditionValue = event.currentTarget.dataset.conditionValue

    if (conditionType === "keyword") {
      this.keywordTarget.value = ""
      this.update()
      return
    }

    const checkbox = this.checkboxTargets.find(target => {
      return target.dataset.conditionType === conditionType && target.value === conditionValue
    })

    if (checkbox) {
      checkbox.checked = false
    }

    this.update()
  }

  selectedConditions() {
    const checkboxConditions = this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => {
        return {
          type: checkbox.dataset.conditionType,
          value: checkbox.value,
          label: checkbox.dataset.conditionLabel
        }
      })

    const keyword = this.keywordTarget.value.trim()
    if (keyword.length === 0) {
      return checkboxConditions
    }

    return [
      ...checkboxConditions,
      {
        type: "keyword",
        value: keyword,
        label: `${this.keywordLabelPrefix}: ${keyword}`
      }
    ]
  }

  buildChip(condition) {
    const chip = document.createElement("span")
    chip.className = "inline-flex items-center gap-1.5 rounded-full border border-gray-200 bg-white px-3 py-1 text-xs font-semibold text-gray-700 shadow-sm"

    const label = document.createElement("span")
    label.textContent = condition.label
    chip.appendChild(label)

    const button = document.createElement("button")
    button.type = "button"
    button.className = "cursor-pointer text-gray-400 transition-colors hover:text-amber-700"
    button.textContent = "×"
    button.dataset.action = "click->cafe-search-conditions#remove"
    button.dataset.conditionType = condition.type
    button.dataset.conditionValue = condition.value
    chip.appendChild(button)

    return chip
  }
}
