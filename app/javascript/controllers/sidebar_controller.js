import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "panel", "panelToggle", "group", "groupPanel", "groupChevron", "item" ]
  static classes = [ "collapsed", "expanded" ]

  connect() {
    // The mobile nav drawer reuses this controller for its group accordions
    // but has no rail to collapse (no panelToggle/panel target) — nothing to
    // restore there.
    if (this.hasPanelTarget && localStorage.getItem("sidebar:collapsed") === "true") this.collapse()
  }

  toggle() {
    this.panelTarget.classList.contains(this.collapsedClass) ? this.expand() : this.collapse()
  }

  // Width is swapped (remove one, add the other) rather than just adding the
  // collapsed class on top of the expanded one: two width utilities of equal
  // specificity on the same element race in the compiled stylesheet, and
  // whichever Tailwind happens to emit last silently wins regardless of
  // which class was added most recently in the DOM.
  collapse() {
    this.panelTarget.classList.remove(this.expandedClass)
    this.panelTarget.classList.add(this.collapsedClass)
    this.panelTarget.dataset.collapsed = "true"
    if (this.hasPanelToggleTarget) this.panelToggleTarget.setAttribute("aria-expanded", "false")
    localStorage.setItem("sidebar:collapsed", "true")
  }

  expand() {
    this.panelTarget.classList.remove(this.collapsedClass)
    this.panelTarget.classList.add(this.expandedClass)
    delete this.panelTarget.dataset.collapsed
    if (this.hasPanelToggleTarget) this.panelToggleTarget.setAttribute("aria-expanded", "true")
    localStorage.setItem("sidebar:collapsed", "false")
  }

  toggleGroup(event) {
    const group = event.currentTarget.closest('[data-sidebar-target~="group"]')
    const panel = group.querySelector('[data-sidebar-target~="groupPanel"]')
    const chevron = group.querySelector('[data-sidebar-target~="groupChevron"]')
    const isOpen = !panel.hidden

    panel.hidden = isOpen
    // The chevron points right when closed and down when open, so the rotation
    // is a quarter turn — not the half turn a chevron-down glyph would need.
    chevron?.classList.toggle("rotate-90", !isOpen)
    event.currentTarget.classList.toggle("bg-item-active", !isOpen)
    event.currentTarget.setAttribute("aria-expanded", String(!isOpen))
  }
}
