import { Controller } from "@hotwired/stimulus"
import { positionAtPoint, onClickOutside } from "../utils/floating"
import { openPanel, closePanel } from "../utils/transition"

export default class extends Controller {
  static targets = [ "panel" ]

  open(event) {
    event.preventDefault()
    openPanel(this.panelTarget)
    positionAtPoint(this.panelTarget, event.clientX, event.clientY)
    this.stopWatchingOutside = onClickOutside([ this.panelTarget ], () => this.close())
  }

  close() {
    closePanel(this.panelTarget)
    this.stopWatchingOutside?.()
  }

  select(event) {
    this.dispatch("select", { detail: { value: event.currentTarget.dataset.value } })
    this.close()
  }

  disconnect() {
    this.stopWatchingOutside?.()
  }
}
