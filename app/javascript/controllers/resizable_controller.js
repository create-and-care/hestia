import { Controller } from "@hotwired/stimulus"

const KEYBOARD_STEP = 20 // px nudge per arrow-key press

export default class extends Controller {
  static targets = [ "first", "handle" ]

  startDrag(event) {
    event.preventDefault()
    this.startX = event.clientX
    this.startWidth = this.firstTarget.getBoundingClientRect().width
    this.onDrag = this.drag.bind(this)
    this.onStop = this.stopDrag.bind(this)
    document.addEventListener("pointermove", this.onDrag)
    document.addEventListener("pointerup", this.onStop)
  }

  drag(event) {
    const delta = event.clientX - this.startX
    this.resizeTo(this.startWidth + delta)
  }

  stopDrag() {
    document.removeEventListener("pointermove", this.onDrag)
    document.removeEventListener("pointerup", this.onStop)
  }

  nudge(event) {
    if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return

    event.preventDefault()
    const delta = event.key === "ArrowRight" ? KEYBOARD_STEP : -KEYBOARD_STEP
    this.resizeTo(this.firstTarget.getBoundingClientRect().width + delta)
  }

  // Shared by pointer-drag and keyboard nudging: clamps the first pane's
  // width within the container and keeps the separator's ARIA value in sync.
  resizeTo(newWidth) {
    const containerWidth = this.element.getBoundingClientRect().width
    const clampedWidth = Math.min(Math.max(newWidth, 80), containerWidth - 80)
    this.firstTarget.style.width = `${clampedWidth}px`
    this.firstTarget.style.flex = "0 0 auto"

    if (this.hasHandleTarget) {
      const percent = Math.round((clampedWidth / containerWidth) * 100)
      this.handleTarget.setAttribute("aria-valuenow", String(percent))
    }
  }
}
