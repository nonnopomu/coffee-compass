import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "checkbox",
    "detailCheckbox",
    "limitMessage",
    "detailLimitMessage",
    "orderBadge",
    "imagePanel",
    "detailPanel",
    "modeSwitchButton",
    "modeSwitchLabel",
    "orderedIds",
    "detailSelectedCount",
    "detailChildren",
    "detailAccordionButton",
    "detailAccordionIcon"
  ]
  static values = {
    max: Number,
    imageModeLabel: String,
    detailModeLabel: String
  }

  connect() {
    const orderedIds = this.initialOrderedIds

    this.selectedIds = this.selectedIdsFromTargets(this.checkboxTargets, orderedIds)
    this.detailSelectedIds = this.selectedIdsFromTargets(this.detailCheckboxTargets, orderedIds)

    this.currentMode = this.selectedDetailGroupIds.length > 0 ? "detail" : "image"
    this.expandedDetailGroupIds = [...this.selectedDetailGroupIds]

    this.update()
    this.updateMode()
    this.updateDetailAvailability()
    this.updateOrderedIds()
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
      this.clearDetailSelections()
      this.selectedIds = this.appendSelectedId(this.selectedIds, checkbox.value)
    } else {
      this.selectedIds = this.selectedIds.filter((id) => id !== checkbox.value)
    }

    this.hideLimitMessage()
    this.update()
    this.updateOrderedIds()
  }

  toggleDetail(event) {
    const checkbox = event.currentTarget

    if (checkbox.checked) {
      this.clearBeginnerSelections()

      if (this.selectedDetailGroupIds.length > this.maxValue) {
        checkbox.checked = false
        this.showDetailLimitMessage()
        this.updateDetailAvailability()
        return
      }

      this.detailSelectedIds = this.appendSelectedId(this.detailSelectedIds, checkbox.value)
    } else {
      this.detailSelectedIds = this.detailSelectedIds.filter((id) => id !== checkbox.value)
    }

    this.hideLimitMessage()
    this.hideDetailLimitMessage()
    this.updateDetailAvailability()
    this.updateOrderedIds()
  }

  selectImageMode() {
    this.currentMode = "image"
    this.clearDetailSelections()
    this.expandedDetailGroupIds = []
    this.updateMode()
    this.updateDetailAccordions()
    this.updateOrderedIds()
  }

  selectDetailMode() {
    this.currentMode = "detail"
    this.clearBeginnerSelections()
    this.updateMode()
    this.updateOrderedIds()
  }

  toggleMode() {
    if (this.currentMode === "image") {
      this.selectDetailMode()
    } else {
      this.selectImageMode()
    }
  }

  toggleDetailGroup(event) {
    const groupId = event.currentTarget.dataset.flavorGroupId

    if (this.expandedDetailGroupIds.includes(groupId)) {
      this.expandedDetailGroupIds = this.expandedDetailGroupIds.filter((id) => id !== groupId)
    } else {
      this.expandedDetailGroupIds = [...this.expandedDetailGroupIds, groupId]
    }

    this.updateDetailAccordions()
  }

  updateMode() {
    this.togglePanel(this.imagePanelTarget, this.currentMode === "image")
    this.togglePanel(this.detailPanelTarget, this.currentMode === "detail")

    this.updateModeSwitchButton()
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

  clearBeginnerSelections() {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = false
      checkbox.disabled = false
    })

    this.selectedIds = []
    this.update()
    this.updateOrderedIds()
  }

  clearDetailSelections() {
    if (!this.hasDetailCheckboxTarget) return

    this.detailCheckboxTargets.forEach((checkbox) => {
      checkbox.checked = false
      checkbox.disabled = false
    })

    this.detailSelectedIds = []
    this.hideDetailLimitMessage()
    this.updateDetailAvailability()
    this.updateOrderedIds()
  }

  updateDetailAvailability() {
    if (!this.hasDetailCheckboxTarget) return

    const selectedGroupIds = this.selectedDetailGroupIds
    const reachedLimit = selectedGroupIds.length >= this.maxValue

    this.detailCheckboxTargets.forEach((checkbox) => {
      const groupSelected = selectedGroupIds.includes(checkbox.dataset.flavorGroupId)
      checkbox.disabled = reachedLimit && !groupSelected
    })

    this.updateDetailSelectionCounts()
    this.updateDetailAccordions()
  }

  updateDetailSelectionCounts() {
    if (!this.hasDetailSelectedCountTarget) return

    this.detailSelectedCountTargets.forEach((countBadge) => {
      const selectedCount = this.detailCheckboxTargets.filter((checkbox) => {
        return checkbox.dataset.flavorGroupId === countBadge.dataset.flavorGroupId && checkbox.checked
      }).length

      countBadge.textContent = selectedCount === 0 ? "" : this.formatSelectedCount(selectedCount)
      countBadge.classList.toggle("hidden", selectedCount === 0)
      countBadge.classList.toggle("inline-flex", selectedCount > 0)
    })
  }

  formatSelectedCount(count) {
    const circledCounts = {
      1: "①",
      2: "②",
      3: "③",
      4: "④",
      5: "⑤",
      6: "⑥",
      7: "⑦",
      8: "⑧",
      9: "⑨"
    }

    return circledCounts[count] || String(count)
  }

  updateDetailAccordions() {
    if (!this.hasDetailChildrenTarget) return

    this.detailChildrenTargets.forEach((container) => {
      container.classList.toggle("hidden", !this.expandedDetailGroupIds.includes(container.dataset.flavorGroupId))
    })

    this.detailAccordionButtonTargets.forEach((button) => {
      const expanded = this.expandedDetailGroupIds.includes(button.dataset.flavorGroupId)
      button.setAttribute("aria-expanded", expanded)
    })

    this.detailAccordionIconTargets.forEach((icon) => {
      icon.classList.toggle("rotate-180", this.expandedDetailGroupIds.includes(icon.dataset.flavorGroupId))
    })
  }

  showDetailLimitMessage() {
    if (!this.hasDetailLimitMessageTarget) return

    this.detailLimitMessageTarget.classList.remove("hidden")
  }

  hideDetailLimitMessage() {
    if (!this.hasDetailLimitMessageTarget) return

    this.detailLimitMessageTarget.classList.add("hidden")
  }

  get selectedCount() {
    return this.selectedIds.length
  }

  get selectedDetailGroupIds() {
    if (!this.hasDetailCheckboxTarget) return []

    return [
      ...new Set(
        this.detailCheckboxTargets
          .filter((checkbox) => checkbox.checked)
          .map((checkbox) => checkbox.dataset.flavorGroupId)
      )
    ]
  }

  togglePanel(panel, visible) {
    panel.classList.toggle("hidden", !visible)
  }

  updateModeSwitchButton() {
    const nextModeLabel = this.currentMode === "image" ? this.detailModeLabelValue : this.imageModeLabelValue

    this.modeSwitchLabelTargets.forEach((label) => {
      label.textContent = nextModeLabel
    })

    this.modeSwitchButtonTargets.forEach((button) => {
      button.setAttribute("aria-label", nextModeLabel)
    })
  }

  appendSelectedId(selectedIds, id) {
    return selectedIds.includes(id) ? selectedIds : [...selectedIds, id]
  }

  updateOrderedIds() {
    if (!this.hasOrderedIdsTarget) return

    const activeIds = this.currentMode === "detail"
      ? this.activeSelectedIds(this.detailSelectedIds, this.detailCheckboxTargets)
      : this.activeSelectedIds(this.selectedIds, this.checkboxTargets)

    this.orderedIdsTarget.value = activeIds.join(",")
  }

  activeSelectedIds(selectedIds, checkboxes) {
    return selectedIds.filter((id) => {
      return checkboxes.some((checkbox) => checkbox.value === id && checkbox.checked)
    })
  }

  selectedIdsFromTargets(checkboxes, orderedIds) {
    const checkedIds = checkboxes
      .filter((checkbox) => checkbox.checked)
      .map((checkbox) => checkbox.value)

    return [
      ...orderedIds.filter((id) => checkedIds.includes(id)),
      ...checkedIds.filter((id) => !orderedIds.includes(id))
    ]
  }

  get initialOrderedIds() {
    if (!this.hasOrderedIdsTarget) return []

    return this.orderedIdsTarget.value.split(",").filter(Boolean)
  }
}
