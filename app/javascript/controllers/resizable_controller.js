import { Controller } from "@hotwired/stimulus"

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
    const containerWidth = this.element.getBoundingClientRect().width
    const newWidth = Math.min(Math.max(this.startWidth + delta, 80), containerWidth - 80)
    this.firstTarget.style.width = `${newWidth}px`
    this.firstTarget.style.flex = "0 0 auto"
  }

  stopDrag() {
    document.removeEventListener("pointermove", this.onDrag)
    document.removeEventListener("pointerup", this.onStop)
  }
}
