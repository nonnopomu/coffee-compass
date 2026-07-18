import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "keyword", "chips", "empty", "suggestions", "suggestionsList"]
  static values = {
    keywordLabelPrefix: String,
    searchSuggestionsUrl: String
  }

  connect() {
    this.appliedKeyword = this.keywordTarget.value.trim()
    this.abortController = null
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

  keywordChanged() {
    this.fetchSuggestions()
  }

  showSuggestions() {
    if (this.keywordTarget.value.trim().length > 0) {
      this.fetchSuggestions()
    }
  }

  closeSuggestionsOnOutside(event) {
    if (this.hasSuggestionsTarget && !this.element.contains(event.target)) {
      this.hideSuggestions()
    }
  }

  remove(event) {
    const conditionType = event.currentTarget.dataset.conditionType
    const conditionValue = event.currentTarget.dataset.conditionValue

    if (conditionType === "keyword") {
      this.appliedKeyword = ""
      this.keywordTarget.value = ""
      this.hideSuggestions()
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

    if (this.appliedKeyword.length === 0) {
      return checkboxConditions
    }

    return [
      ...checkboxConditions,
      {
        type: "keyword",
        value: this.appliedKeyword,
        label: `${this.keywordLabelPrefixValue}: ${this.appliedKeyword}`
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

  fetchSuggestions() {
    if (!this.hasSearchSuggestionsUrlValue || !this.hasSuggestionsTarget || !this.hasSuggestionsListTarget) {
      return
    }

    const keyword = this.keywordTarget.value.trim()

    if (keyword.length === 0) {
      this.hideSuggestions()
      return
    }

    if (this.abortController) {
      this.abortController.abort()
    }

    this.abortController = new AbortController()
    const url = new URL(this.searchSuggestionsUrlValue, window.location.origin)
    url.searchParams.set("keyword", keyword)

    fetch(url, {
      headers: { Accept: "application/json" },
      signal: this.abortController.signal
    })
      .then(response => {
        if (!response.ok) {
          throw new Error(`Request failed: ${response.status}`)
        }

        return response.json()
      })
      .then(data => {
        this.renderSuggestions(data.suggestions || [])
      })
      .catch(error => {
        if (error.name !== "AbortError") {
          this.hideSuggestions()
        }
      })
  }

  renderSuggestions(suggestions) {
    this.suggestionsListTarget.replaceChildren()

    if (suggestions.length === 0) {
      this.hideSuggestions()
      return
    }

    suggestions.forEach(suggestion => {
      this.suggestionsListTarget.appendChild(this.buildSuggestionButton(suggestion))
    })

    this.suggestionsTarget.classList.remove("hidden")
  }

  buildSuggestionButton(suggestion) {
    const button = document.createElement("button")
    button.type = "button"
    button.className = "flex w-full cursor-pointer flex-col px-4 py-2.5 text-left transition-colors hover:bg-amber-50 focus:bg-amber-50 focus:outline-none"
    button.dataset.action = "click->cafe-search-conditions#selectSuggestion"
    button.dataset.keyword = suggestion.keyword
    button.setAttribute("role", "option")

    const label = document.createElement("span")
    label.className = "text-sm font-semibold text-gray-900"
    label.textContent = suggestion.label
    button.appendChild(label)

    return button
  }

  selectSuggestion(event) {
    this.keywordTarget.value = event.currentTarget.dataset.keyword || ""
    this.hideSuggestions()
  }

  hideSuggestions() {
    if (!this.hasSuggestionsTarget || !this.hasSuggestionsListTarget) {
      return
    }

    this.suggestionsListTarget.replaceChildren()
    this.suggestionsTarget.classList.add("hidden")
  }
}
