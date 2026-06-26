import { Controller } from "@hotwired/stimulus"
import { measureContentHeight } from "../utils/transition"

export default class extends Controller {
  static targets = [ "trigger", "panel" ]
  static values = { multiple: { type: Boolean, default: false } }

  toggle(event) {
    const trigger = event.currentTarget
    const panel = this.panelTargets.find((p) => p.dataset.key === trigger.dataset.key)
    const willOpen = panel.hidden || panel.dataset.state === "closed"

    if (!this.multipleValue) {
      this.panelTargets.forEach((p) => { if (p !== panel) this.closePanel(p) })
      this.triggerTargets.forEach((t) => { if (t !== trigger) t.setAttribute("aria-expanded", "false") })
    }

    willOpen ? this.openPanel(panel) : this.closePanel(panel)
    trigger.setAttribute("aria-expanded", String(willOpen))
  }

  openPanel(panel) {
    clearTimeout(panel._hideTimer)
    panel.hidden = false
    measureContentHeight(panel)
    panel.dataset.state = "open"
  }

  closePanel(panel) {
    if (panel.hidden) return
    measureContentHeight(panel)
    panel.dataset.state = "closed"
    panel._hideTimer = setTimeout(() => { panel.hidden = true }, 200)
  }
}
