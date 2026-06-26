import { Controller } from "@hotwired/stimulus"
import { measureContentHeight } from "../utils/transition"

export default class extends Controller {
  static targets = [ "trigger", "panel" ]

  toggle() {
    this.panelTarget.hidden || this.panelTarget.dataset.state === "closed" ? this.open() : this.close()
  }

  open() {
    clearTimeout(this.panelTarget._hideTimer)
    this.panelTarget.hidden = false
    measureContentHeight(this.panelTarget)
    this.panelTarget.dataset.state = "open"
    this.triggerTarget?.setAttribute("aria-expanded", "true")
  }

  close() {
    measureContentHeight(this.panelTarget)
    this.panelTarget.dataset.state = "closed"
    this.triggerTarget?.setAttribute("aria-expanded", "false")
    this.panelTarget._hideTimer = setTimeout(() => { this.panelTarget.hidden = true }, 200)
  }
}
