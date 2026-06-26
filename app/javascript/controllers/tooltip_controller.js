import { Controller } from "@hotwired/stimulus"
import { positionFloating } from "../utils/floating"
import { openPanel, closePanel } from "../utils/transition"

export default class extends Controller {
  static targets = [ "trigger", "panel" ]
  static values = { delay: { type: Number, default: 200 } }

  show() {
    clearTimeout(this.hideTimeout)
    this.showTimeout = setTimeout(() => {
      openPanel(this.panelTarget)
      positionFloating(this.triggerTarget, this.panelTarget, { placement: "top-start" })
    }, this.delayValue)
  }

  hide() {
    clearTimeout(this.showTimeout)
    this.hideTimeout = setTimeout(() => { closePanel(this.panelTarget, { duration: 100 }) }, 80)
  }

  disconnect() {
    clearTimeout(this.showTimeout)
    clearTimeout(this.hideTimeout)
  }
}
