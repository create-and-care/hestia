import { Controller } from "@hotwired/stimulus"
import { positionFloating, onClickOutside } from "../utils/floating"
import { openPanel, closePanel } from "../utils/transition"

export default class extends Controller {
  static targets = [ "trigger", "panel", "item", "input", "label" ]

  toggle() {
    this.panelTarget.hidden ? this.open() : this.close()
  }

  open() {
    openPanel(this.panelTarget)
    positionFloating(this.triggerTarget, this.panelTarget, { placement: "bottom-start" })
    this.stopWatchingOutside = onClickOutside([ this.triggerTarget, this.panelTarget ], () => this.close())
  }

  close() {
    closePanel(this.panelTarget)
    this.stopWatchingOutside?.()
  }

  select(event) {
    const { value, label } = event.currentTarget.dataset
    this.inputTarget.value = value
    this.labelTarget.textContent = label || event.currentTarget.textContent.trim()
    this.itemTargets.forEach((item) => item.setAttribute("aria-selected", String(item === event.currentTarget)))
    this.dispatch("select", { detail: { value } })
    this.close()
  }

  disconnect() {
    this.stopWatchingOutside?.()
  }
}
