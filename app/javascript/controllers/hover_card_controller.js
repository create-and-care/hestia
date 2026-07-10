import { Controller } from "@hotwired/stimulus"
import { positionFloating } from "../utils/floating"
import { openPanel, closePanel } from "../utils/transition"

export default class extends Controller {
  static targets = [ "trigger", "panel" ]
  static values = { openDelay: { type: Number, default: 400 }, closeDelay: { type: Number, default: 200 } }

  show() {
    clearTimeout(this.hideTimeout)
    this.showTimeout = setTimeout(() => {
      openPanel(this.panelTarget)
      positionFloating(this.triggerTarget, this.panelTarget, { placement: "bottom-start" })
      document.addEventListener("keydown", this.onKeydown)
    }, this.openDelayValue)
  }

  hide() {
    clearTimeout(this.showTimeout)
    this.hideTimeout = setTimeout(() => {
      closePanel(this.panelTarget)
      document.removeEventListener("keydown", this.onKeydown)
    }, this.closeDelayValue)
  }

  onKeydown = (event) => {
    if (event.key === "Escape") this.hide()
  }

  disconnect() {
    clearTimeout(this.showTimeout)
    clearTimeout(this.hideTimeout)
    document.removeEventListener("keydown", this.onKeydown)
  }
}
