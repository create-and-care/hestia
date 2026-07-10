import { Controller } from "@hotwired/stimulus"

// Filterable list used standalone (command palette) and embedded in combobox.
export default class extends Controller {
  static targets = [ "input", "item", "empty" ]

  connect() {
    this.activeItem = null
    this.setActive(this.visibleItems()[0])
  }

  filter() {
    const query = this.inputTarget.value.trim().toLowerCase()
    let visibleCount = 0

    this.itemTargets.forEach((item) => {
      const matches = item.textContent.trim().toLowerCase().includes(query)
      item.hidden = !matches
      if (matches) visibleCount++
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = visibleCount > 0
    this.setActive(this.visibleItems()[0])
  }

  onKeydown(event) {
    if (event.key === "ArrowDown") { event.preventDefault(); this.moveActive(1); return }
    if (event.key === "ArrowUp") { event.preventDefault(); this.moveActive(-1); return }
    if (event.key === "Enter") { event.preventDefault(); this.activeItem?.click(); return }
    if (event.key === "Escape") { this.onEscape(event) }
  }

  // Mirrors dropdown-menu's wraparound arithmetic, but keeps DOM focus on the
  // input (combobox convention) and moves an "active" item highlight instead,
  // exposed to assistive tech via aria-activedescendant.
  moveActive(delta) {
    const items = this.visibleItems()
    if (!items.length) return

    const currentIndex = items.indexOf(this.activeItem)
    const nextIndex = (currentIndex + delta + items.length) % items.length
    this.setActive(items[nextIndex])
  }

  setActive(item) {
    this.itemTargets.forEach((i) => {
      i.setAttribute("aria-selected", "false")
      i.classList.remove("bg-surface-hover")
    })

    this.activeItem = item || null

    if (item) {
      item.setAttribute("aria-selected", "true")
      item.classList.add("bg-surface-hover")
    }

    this.inputTarget.setAttribute("aria-activedescendant", item?.id || "")
  }

  visibleItems() {
    return this.itemTargets.filter((item) => !item.hidden)
  }

  select(event) {
    this.dispatch("select", { detail: { value: event.currentTarget.dataset.value, label: event.currentTarget.textContent.trim() } })
  }

  // Command has no open/closed state of its own here (it's rendered
  // standalone, not inside a Dialog/Popover — see design_system preview).
  // First Escape clears an active filter; if the input is already empty we
  // don't stop the event, so an ancestor popover/dropdown's own Escape
  // handler (or a native <dialog>'s default Escape-to-close) still fires.
  onEscape(event) {
    if (!this.inputTarget.value) return

    event.stopPropagation()
    this.inputTarget.value = ""
    this.filter()
  }
}
