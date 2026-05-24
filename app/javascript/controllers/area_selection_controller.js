import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "chips", "count"]

  update() {
    const selected = this.checkboxTargets.filter(cb => cb.checked).map(cb => cb.value)

    // 選択中チップを更新する
    this.chipsTarget.innerHTML = selected.map(prefecture => `
      <span class="flex items-center gap-1 bg-white border border-gray-300 text-sm text-gray-700 rounded-full px-3 py-1">
        ${prefecture}
        <button type="button" data-prefecture="${prefecture}" data-action="click->area-selection#remove" class="text-gray-400 hover:text-gray-600">×</button>
      </span>
    `).join("")

    // 選択件数を更新する
    this.countTarget.textContent = selected.length
  }

  remove(event) {
    const prefecture = event.currentTarget.dataset.prefecture
    const checkbox = this.checkboxTargets.find(cb => cb.value === prefecture)
    if (checkbox) {
      checkbox.checked = false
      this.update()
    }
  }
}
