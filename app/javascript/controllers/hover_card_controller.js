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
    }, this.openDelayValue)
  }

  hide() {
    clearTimeout(this.showTimeout)
    this.hideTimeout = setTimeout(() => { closePanel(this.panelTarget) }, this.closeDelayValue)
  }

  disconnect() {
    clearTimeout(this.showTimeout)
    clearTimeout(this.hideTimeout)
  }
}
