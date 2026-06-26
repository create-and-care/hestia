import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "item", "input" ]
  static values = { multiple: { type: Boolean, default: false } }

  toggle(event) {
    const item = event.currentTarget
    const pressed = item.getAttribute("aria-pressed") === "true"

    if (!this.multipleValue) {
      this.itemTargets.forEach((el) => el.setAttribute("aria-pressed", "false"))
    }
    item.setAttribute("aria-pressed", String(!pressed))

    if (this.hasInputTarget) {
      const values = this.itemTargets.filter((el) => el.getAttribute("aria-pressed") === "true").map((el) => el.dataset.value)
      this.inputTarget.value = this.multipleValue ? values.join(",") : (values[0] || "")
    }
  }
}
