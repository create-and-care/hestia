import { Controller } from "@hotwired/stimulus"
import { positionFloating, onClickOutside } from "../utils/floating"
import { openPanel, closePanel } from "../utils/transition"

export default class extends Controller {
  static targets = [ "trigger", "panel", "search", "item", "empty", "input", "label" ]

  toggle() {
    this.panelTarget.hidden ? this.open() : this.close()
  }

  open() {
    openPanel(this.panelTarget)
    positionFloating(this.triggerTarget, this.panelTarget, { placement: "bottom-start" })
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.searchTarget.value = ""
    this.filter()
    this.searchTarget.focus()
    this.stopWatchingOutside = onClickOutside([ this.triggerTarget, this.panelTarget ], () => this.close())
  }

  close() {
    closePanel(this.panelTarget)
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.searchTarget.removeAttribute("aria-activedescendant")
    this.stopWatchingOutside?.()
  }

  filter() {
    const query = this.searchTarget.value.trim().toLowerCase()
    let visibleCount = 0
    this.itemTargets.forEach((item) => {
      const matches = item.textContent.trim().toLowerCase().includes(query)
      item.hidden = !matches
      if (matches) visibleCount++
    })
    if (this.hasEmptyTarget) this.emptyTarget.hidden = visibleCount > 0
    this.searchTarget.removeAttribute("aria-activedescendant")
  }

  onSearchKeydown(event) {
    const items = this.itemTargets.filter((item) => !item.hidden)

    if (event.key === "Escape") { event.preventDefault(); this.close(); return }

    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault()
      if (!items.length) return

      const currentIndex = items.findIndex((item) => item.id === this.searchTarget.getAttribute("aria-activedescendant"))
      const delta = event.key === "ArrowDown" ? 1 : -1
      const nextIndex = currentIndex === -1 ? 0 : (currentIndex + delta + items.length) % items.length
      this.searchTarget.setAttribute("aria-activedescendant", items[nextIndex].id)
      return
    }

    if (event.key === "Enter") {
      event.preventDefault()
      const activeItem = items.find((item) => item.id === this.searchTarget.getAttribute("aria-activedescendant"))
      ;(activeItem || items[0])?.click()
    }
  }

  select(event) {
    const { value, label } = event.currentTarget.dataset
    if (this.hasInputTarget) this.inputTarget.value = value
    this.labelTarget.textContent = label || event.currentTarget.textContent.trim()
    this.dispatch("select", { detail: { value } })
    this.close()
  }

  disconnect() {
    this.stopWatchingOutside?.()
  }
}
