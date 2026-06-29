import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "displayOrder", "tasteOptions", "kind", "parentSection", "parentSelect"]
  static values = {
    autoOrder: Boolean,
    nextDisplayOrders: Object,
    tasteCategory: String
  }

  connect() {
    this.sync()
  }

  categoryChanged() {
    if (this.autoOrderValue) this.setNextDisplayOrder()
    this.sync()
  }

  kindChanged() {
    this.sync()
  }

  sync() {
    const isTasteCategory = this.categoryTarget.value === this.tasteCategoryValue

    this.tasteOptionsTarget.classList.toggle("hidden", !isTasteCategory)

    if (!isTasteCategory) {
      this.clearParent()
      return
    }

    const isChildTag = this.selectedKind() === "child"
    this.parentSectionTarget.classList.toggle("hidden", !isChildTag)

    if (!isChildTag) this.clearParent()
  }

  setNextDisplayOrder() {
    const category = this.categoryTarget.value
    const nextDisplayOrder = this.nextDisplayOrdersValue[category]

    if (nextDisplayOrder) this.displayOrderTarget.value = nextDisplayOrder
  }

  selectedKind() {
    const selected = this.kindTargets.find((kind) => kind.checked)
    return selected ? selected.value : "parent"
  }

  clearParent() {
    this.parentSelectTarget.value = ""
  }
}
