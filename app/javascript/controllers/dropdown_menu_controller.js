import { Controller } from "@hotwired/stimulus"
import { positionFloating, onClickOutside } from "../utils/floating"
import { openPanel, closePanel } from "../utils/transition"

// Used by dropdown-menu and menubar.
export default class extends Controller {
  static targets = [ "trigger", "panel", "item" ]
  static values = { placement: { type: String, default: "bottom-start" } }

  toggle() {
    this.panelTarget.hidden ? this.show() : this.hide()
  }

  show() {
    openPanel(this.panelTarget)
    positionFloating(this.triggerTarget, this.panelTarget, { placement: this.placementValue })
    this.stopWatchingOutside = onClickOutside([ this.triggerTarget, this.panelTarget ], () => this.hide())
    document.addEventListener("keydown", this.onKeydown)
    this.itemTargets[0]?.focus()
  }

  hide() {
    closePanel(this.panelTarget)
    this.stopWatchingOutside?.()
    document.removeEventListener("keydown", this.onKeydown)
    this.triggerTarget.focus()
  }

  select(event) {
    this.dispatch("select", { detail: { value: event.currentTarget.dataset.value } })
    this.hide()
  }

  onKeydown = (event) => {
    const items = this.itemTargets
    const currentIndex = items.indexOf(document.activeElement)

    if (event.key === "Escape") { this.hide(); return }
    if (event.key === "ArrowDown") { event.preventDefault(); items[(currentIndex + 1) % items.length]?.focus() }
    if (event.key === "ArrowUp") { event.preventDefault(); items[(currentIndex - 1 + items.length) % items.length]?.focus() }
  }

  disconnect() {
    this.stopWatchingOutside?.()
    document.removeEventListener("keydown", this.onKeydown)
  }
}
