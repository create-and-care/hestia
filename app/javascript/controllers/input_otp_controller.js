import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "box", "input" ]

  type(event) {
    const box = event.currentTarget
    const index = this.boxTargets.indexOf(box)
    box.value = box.value.slice(-1)

    if (box.value && index < this.boxTargets.length - 1) this.boxTargets[index + 1].focus()
    this.sync()
  }

  navigate(event) {
    const box = event.currentTarget
    const index = this.boxTargets.indexOf(box)

    if (event.key === "Backspace" && !box.value && index > 0) this.boxTargets[index - 1].focus()
    if (event.key === "ArrowLeft" && index > 0) this.boxTargets[index - 1].focus()
    if (event.key === "ArrowRight" && index < this.boxTargets.length - 1) this.boxTargets[index + 1].focus()
  }

  paste(event) {
    event.preventDefault()
    const chars = (event.clipboardData.getData("text") || "").trim().split("")
    this.boxTargets.forEach((box, index) => { box.value = chars[index] || "" })
    this.boxTargets[Math.min(chars.length, this.boxTargets.length - 1)]?.focus()
    this.sync()
  }

  sync() {
    if (this.hasInputTarget) this.inputTarget.value = this.boxTargets.map((box) => box.value).join("")
  }
}
