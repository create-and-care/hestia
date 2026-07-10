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
    trigger.setAttribute("aria-expanded", "true")
    this.openTrigger = trigger
    this.openPanelEl = panel
    this.stopWatchingOutside = onClickOutside([ ...this.triggerTargets, ...this.panelTargets ], () => this.closeAll())
    document.addEventListener("keydown", this.onKeydown)
  }

  closeAll() {
    this.panelTargets.forEach((panel) => { if (!panel.hidden) closePanel(panel) })
    this.triggerTargets.forEach((trigger) => trigger.setAttribute("aria-expanded", "false"))
    this.openPanelEl = null
    this.openTrigger = null
    this.stopWatchingOutside?.()
    document.removeEventListener("keydown", this.onKeydown)
  }

  onKeydown = (event) => {
    if (event.key !== "Escape") return
    const trigger = this.openTrigger
    this.closeAll()
    trigger?.focus()
  }

  onTriggerKeydown(event) {
    if (event.key !== "ArrowRight" && event.key !== "ArrowLeft") return

    const triggers = this.triggerTargets
    const currentIndex = triggers.indexOf(event.currentTarget)
    if (currentIndex === -1) return

    event.preventDefault()
    const delta = event.key === "ArrowRight" ? 1 : -1
    triggers[(currentIndex + delta + triggers.length) % triggers.length]?.focus()
  }

  disconnect() {
    this.stopWatchingOutside?.()
    document.removeEventListener("keydown", this.onKeydown)
  }
}
