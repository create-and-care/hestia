import { Controller } from "@hotwired/stimulus"
import { positionFloating, onClickOutside } from "../utils/floating"
import { openPanel, closePanel } from "../utils/transition"

export default class extends Controller {
  static targets = [ "trigger", "panel", "search", "item", "empty", "input", "label" ]

  toggle() {
    this.panelTarget.hidden ? this.open() : this.close()
  }

  open() {
    openPanel(this.panelTarget)
    positionFloating(this.triggerTarget, this.panelTarget, { placement: "bottom-start" })
    this.searchTarget.value = ""
    this.filter()
    this.searchTarget.focus()
    this.stopWatchingOutside = onClickOutside([ this.triggerTarget, this.panelTarget ], () => this.close())
  }

  close() {
    closePanel(this.panelTarget)
    this.stopWatchingOutside?.()
  }

  filter() {
    const query = this.searchTarget.value.trim().toLowerCase()
    let visibleCount = 0
    this.itemTargets.forEach((item) => {
      const matches = item.textContent.trim().toLowerCase().includes(query)
      item.hidden = !matches
      if (matches) visibleCount++
    })
    if (this.hasEmptyTarget) this.emptyTarget.hidden = visibleCount > 0
  }

  select(event) {
    const { value, label } = event.currentTarget.dataset
    if (this.hasInputTarget) this.inputTarget.value = value
    this.labelTarget.textContent = label || event.currentTarget.textContent.trim()
    this.dispatch("select", { detail: { value } })
    this.close()
  }

  disconnect() {
    this.stopWatchingOutside?.()
  }
}
