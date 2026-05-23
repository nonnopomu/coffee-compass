import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  switch(event) {
    const index = parseInt(event.currentTarget.dataset.index)

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
}
