import { Controller } from "@hotwired/stimulus"
import { positionFloating, onClickOutside } from "../utils/floating"
import { openPanel, closePanel } from "../utils/transition"

export default class extends Controller {
  static targets = [ "trigger", "panel", "item", "input", "label" ]

  toggle() {
    this.panelTarget.hidden ? this.open() : this.close()
  }

  open() {
    openPanel(this.panelTarget)
    positionFloating(this.triggerTarget, this.panelTarget, { placement: "bottom-start" })
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.stopWatchingOutside = onClickOutside([ this.triggerTarget, this.panelTarget ], () => this.close())

    const selectedIndex = this.itemTargets.findIndex((item) => item.getAttribute("aria-selected") === "true")
    this.setActive(selectedIndex === -1 ? 0 : selectedIndex)
  }

  close() {
    closePanel(this.panelTarget)
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.triggerTarget.removeAttribute("aria-activedescendant")
    this.stopWatchingOutside?.()
  }

  select(event) {
    const { value, label } = event.currentTarget.dataset
    this.inputTarget.value = value
    this.labelTarget.textContent = label || event.currentTarget.textContent.trim()
    this.itemTargets.forEach((item) => item.setAttribute("aria-selected", String(item === event.currentTarget)))
    this.dispatch("select", { detail: { value } })
    this.close()
  }

  onTriggerKeydown(event) {
    const items = this.itemTargets
    if (!items.length) return

    if (event.key === "Escape") {
      if (!this.panelTarget.hidden) { event.preventDefault(); this.close() }
      return
    }

    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault()
      if (this.panelTarget.hidden) { this.open(); return }

      const currentIndex = items.findIndex((item) => item.id === this.triggerTarget.getAttribute("aria-activedescendant"))
      const delta = event.key === "ArrowDown" ? 1 : -1
      const nextIndex = currentIndex === -1 ? 0 : (currentIndex + delta + items.length) % items.length
      this.setActive(nextIndex)
      return
    }

    if (event.key === "Enter" || event.key === " ") {
      if (this.panelTarget.hidden) return
      event.preventDefault()
      const activeItem = items.find((item) => item.id === this.triggerTarget.getAttribute("aria-activedescendant"))
      activeItem?.click()
    }
  }

  setActive(index) {
    const items = this.itemTargets
    if (index < 0 || index >= items.length) return
    this.triggerTarget.setAttribute("aria-activedescendant", items[index].id)
  }

  disconnect() {
    this.stopWatchingOutside?.()
  }
}
