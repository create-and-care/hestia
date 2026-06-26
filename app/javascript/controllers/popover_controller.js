import { Controller } from "@hotwired/stimulus"
import { positionFloating, onClickOutside } from "../utils/floating"
import { openPanel, closePanel } from "../utils/transition"

export default class extends Controller {
  static targets = [ "trigger", "panel" ]
  static values = { placement: { type: String, default: "bottom-start" } }

  disconnect() {
    this.stopWatchingOutside?.()
  }

  toggle() {
    this.panelTarget.hidden ? this.show() : this.hide()
  }

  show() {
    openPanel(this.panelTarget)
    positionFloating(this.triggerTarget, this.panelTarget, { placement: this.placementValue })
    this.stopWatchingOutside = onClickOutside([ this.triggerTarget, this.panelTarget ], () => this.hide())
    this.escapeHandler = (event) => { if (event.key === "Escape") this.hide() }
    document.addEventListener("keydown", this.escapeHandler)
  }

  hide() {
    closePanel(this.panelTarget)
    this.stopWatchingOutside?.()
    if (this.escapeHandler) document.removeEventListener("keydown", this.escapeHandler)
  }
}
