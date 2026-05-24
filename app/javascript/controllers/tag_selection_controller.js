import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chip", "selected", "count"]

  toggle(event) {
    const button = event.currentTarget
    const tagId = button.dataset.tagId
    const tagName = button.dataset.tagName
    const isSelected = button.dataset.selected === "true"

    if (isSelected) {
      this.deselect(button)
    } else {
      this.select(button, tagId, tagName)
    }

    this.updateCount()
  }

  select(button, tagId, tagName) {
    button.dataset.selected = "true"
    button.classList.add("bg-amber-600", "text-white", "border-amber-600")
    button.classList.remove("bg-white", "text-gray-700", "border-gray-200")

    const chip = document.createElement("span")
    chip.dataset.tagId = tagId
    chip.className = "bg-amber-50 border border-amber-200 text-amber-700 text-xs rounded-full px-3 py-1"
    chip.textContent = tagName
    this.selectedTarget.appendChild(chip)

    const checkbox = document.querySelector(`input[type="checkbox"][data-tag-id="${tagId}"]`)
    if (checkbox) checkbox.checked = true
  }

  deselect(button) {
    button.dataset.selected = "false"
    button.classList.remove("bg-amber-600", "text-white", "border-amber-600")
    button.classList.add("bg-white", "text-gray-700", "border-gray-200")

    const chip = this.selectedTarget.querySelector(`[data-tag-id="${button.dataset.tagId}"]`)
    if (chip) chip.remove()

    const checkbox = document.querySelector(`input[type="checkbox"][data-tag-id="${button.dataset.tagId}"]`)
    if (checkbox) checkbox.checked = false
  }

  reset() {
    this.chipTargets.forEach(button => {
      button.dataset.selected = "false"
      button.classList.remove("bg-amber-600", "text-white", "border-amber-600")
      button.classList.add("bg-white", "text-gray-700", "border-gray-200")
    })
    this.selectedTarget.innerHTML = ""
    this.updateCount()
  }

  updateCount() {
    const count = this.chipTargets.filter(b => b.dataset.selected === "true").length
    this.countTarget.textContent = count
  }
}
