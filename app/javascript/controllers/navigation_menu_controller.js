import { Controller } from "@hotwired/stimulus"
import { positionFloating, onClickOutside } from "../utils/floating"
import { openPanel, closePanel } from "../utils/transition"

export default class extends Controller {
  static targets = [ "trigger", "panel" ]

  toggle(event) {
    const trigger = event.currentTarget
    const panel = this.panelTargets.find((p) => p.dataset.for === trigger.dataset.key)
    if (!panel) return

    const isOpen = panel === this.openPanelEl && !panel.hidden
    this.closeAll()
    if (!isOpen) this.openMenu(trigger, panel)
  }

  openMenu(trigger, panel) {
    openPanel(panel)
    positionFloating(trigger, panel, { placement: "bottom-start" })
    this.openPanelEl = panel
    this.stopWatchingOutside = onClickOutside([ ...this.triggerTargets, ...this.panelTargets ], () => this.closeAll())
  }

  closeAll() {
    this.panelTargets.forEach((panel) => { if (!panel.hidden) closePanel(panel) })
    this.openPanelEl = null
    this.stopWatchingOutside?.()
  }

  disconnect() {
    this.stopWatchingOutside?.()
  }
}
