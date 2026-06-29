import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "limitMessage", "orderBadge"]
  static values = { max: Number }

  connect() {
    this.selectedIds = this.checkboxTargets
      .filter((checkbox) => checkbox.checked)
      .map((checkbox) => checkbox.value)

    this.update()
  }

  toggle(event) {
    const checkbox = event.currentTarget

    if (checkbox.checked && this.selectedIds.length >= this.maxValue) {
      checkbox.checked = false
      this.showLimitMessage()
      this.update()
      return
    }

    if (checkbox.checked) {
      this.selectedIds.push(checkbox.value)
    } else {
      this.selectedIds = this.selectedIds.filter((id) => id !== checkbox.value)
    }

    this.hideLimitMessage()
    this.update()
  }

  update() {
    const reachedLimit = this.selectedCount >= this.maxValue

    this.checkboxTargets.forEach((checkbox, index) => {
      checkbox.disabled = reachedLimit && !checkbox.checked

      const order = this.selectedIds.indexOf(checkbox.value)
      this.orderBadgeTargets[index].textContent = order >= 0 ? order + 1 : ""
    })
  }

  showLimitMessage() {
    if (!this.hasLimitMessageTarget) return

    this.limitMessageTarget.classList.remove("hidden")
  }

  hideLimitMessage() {
    if (!this.hasLimitMessageTarget) return

    this.limitMessageTarget.classList.add("hidden")
  }

  get selectedCount() {
    return this.selectedIds.length
  }
}
