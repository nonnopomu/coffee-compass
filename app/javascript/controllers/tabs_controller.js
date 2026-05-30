import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.activate(this.initialIndex())
  }

  switch(event) {
    const index = parseInt(event.currentTarget.dataset.index)

    this.activate(index)
    this.updateUrl(index)
  }

  activate(index) {
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("text-amber-600", i === index)
      tab.classList.toggle("border-amber-600", i === index)
      tab.classList.toggle("text-gray-400", i !== index)
      tab.classList.toggle("border-transparent", i !== index)
    })

    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle("hidden", i !== index)
    })
  }

  initialIndex() {
    const tabKey = new URLSearchParams(window.location.search).get("tab")
    const index = this.tabTargets.findIndex((tab) => tab.dataset.tabKey === tabKey)

    return index >= 0 ? index : 0
  }

  updateUrl(index) {
    const tabKey = this.tabTargets[index]?.dataset.tabKey
    const url = new URL(window.location.href)

    if (tabKey) {
      url.searchParams.set("tab", tabKey)
    } else {
      url.searchParams.delete("tab")
    }

    window.history.replaceState({}, "", url)
  }
}
