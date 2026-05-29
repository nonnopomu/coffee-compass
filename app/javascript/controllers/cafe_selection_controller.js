import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "option", "value", "selected", "selectedName", "selectedAddress", "message"]

  connect() {
    this.filter()
  }

  filter() {
    const query = this.normalize(this.queryTarget.value)
    let visibleCount = 0

    this.optionTargets.forEach((option) => {
      const matches = query.length > 0 && option.dataset.search.includes(query)
      const shouldShow = matches && visibleCount < 8

      option.classList.toggle("hidden", !shouldShow)
      if (shouldShow) visibleCount += 1
    })

    if (query.length === 0) {
      this.messageTarget.classList.add("hidden")
    } else if (visibleCount === 0) {
      this.messageTarget.textContent = "一致するカフェがありません"
      this.messageTarget.classList.remove("hidden")
    } else {
      this.messageTarget.classList.add("hidden")
    }
  }

  select(event) {
    const option = event.currentTarget

    this.valueTarget.value = option.dataset.cafeId
    this.queryTarget.value = option.dataset.cafeName
    this.selectedNameTarget.textContent = option.dataset.cafeName
    this.selectedAddressTarget.textContent = option.dataset.cafeAddress
    this.selectedTarget.classList.remove("hidden")

    this.optionTargets.forEach((candidate) => candidate.classList.add("hidden"))
    this.messageTarget.classList.add("hidden")
  }

  normalize(text) {
    return text.trim().toLowerCase()
  }
}
