import { Controller } from "@hotwired/stimulus"
import { DURATION } from "../utils/motion"
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
      document.addEventListener("keydown", this.onKeydown)
    }, this.delayValue)
  }

  hide() {
    clearTimeout(this.showTimeout)
    this.hideTimeout = setTimeout(() => {
      closePanel(this.panelTarget, { duration: DURATION.TOOLTIP })
      document.removeEventListener("keydown", this.onKeydown)
    }, DURATION.TOOLTIP_GRACE)
  }

  // WAI-ARIA APG: Escape dismisses the tooltip without moving focus away
  // from the trigger (unlike Dialog/Popover, focus never left the trigger
  // to begin with since this is a hover/focus-triggered tooltip).
  onKeydown = (event) => {
    if (event.key === "Escape") this.hide()
  }

  disconnect() {
    clearTimeout(this.showTimeout)
    clearTimeout(this.hideTimeout)
    document.removeEventListener("keydown", this.onKeydown)
  }
}
