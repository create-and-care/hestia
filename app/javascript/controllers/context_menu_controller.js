import { Controller } from "@hotwired/stimulus"
import { positionAtPoint, onClickOutside } from "../utils/floating"
import { openPanel, closePanel } from "../utils/transition"

export default class extends Controller {
  static targets = [ "panel", "item" ]

  open(event) {
    event.preventDefault()
    this.returnFocusTo = document.activeElement
    openPanel(this.panelTarget)
    positionAtPoint(this.panelTarget, event.clientX, event.clientY)
    this.stopWatchingOutside = onClickOutside([ this.panelTarget ], () => this.close())
    document.addEventListener("keydown", this.onKeydown)
    this.itemTargets[0]?.focus()
  }

  close() {
    closePanel(this.panelTarget)
    this.stopWatchingOutside?.()
    document.removeEventListener("keydown", this.onKeydown)
    this.returnFocusTo?.focus()
  }

  select(event) {
    this.dispatch("select", { detail: { value: event.currentTarget.dataset.value } })
    this.close()
  }

  onKeydown = (event) => {
    const items = this.itemTargets
    const currentIndex = items.indexOf(document.activeElement)

    if (event.key === "Escape") { this.close(); return }
    if (event.key === "ArrowDown") { event.preventDefault(); items[(currentIndex + 1) % items.length]?.focus() }
    if (event.key === "ArrowUp") { event.preventDefault(); items[(currentIndex - 1 + items.length) % items.length]?.focus() }
  }

  disconnect() {
    this.stopWatchingOutside?.()
    document.removeEventListener("keydown", this.onKeydown)
  }
}
