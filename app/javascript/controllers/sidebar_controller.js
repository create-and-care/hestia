import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "panel", "panelToggle", "label", "group", "groupPanel", "groupChevron", "item", "searchInput", "empty" ]
  static classes = [ "collapsed", "expanded" ]

  connect() {
    if (localStorage.getItem("sidebar:collapsed") === "true") this.collapse()
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
    this.labelTargets.forEach((el) => el.classList.add("hidden"))
    if (this.hasPanelToggleTarget) this.panelToggleTarget.setAttribute("aria-expanded", "false")
    localStorage.setItem("sidebar:collapsed", "true")
  }

  expand() {
    this.panelTarget.classList.remove(this.collapsedClass)
    this.panelTarget.classList.add(this.expandedClass)
    this.labelTargets.forEach((el) => el.classList.remove("hidden"))
    if (this.hasPanelToggleTarget) this.panelToggleTarget.setAttribute("aria-expanded", "true")
    localStorage.setItem("sidebar:collapsed", "false")
  }

  toggleGroup(event) {
    const group = event.currentTarget.closest('[data-sidebar-target~="group"]')
    const panel = group.querySelector('[data-sidebar-target~="groupPanel"]')
    const chevron = group.querySelector('[data-sidebar-target~="groupChevron"]')
    const isOpen = !panel.hidden

    panel.hidden = isOpen
    chevron?.classList.toggle("rotate-180", !isOpen)
    event.currentTarget.setAttribute("aria-expanded", String(!isOpen))
  }

  filter() {
    const query = this.searchInputTarget.value.trim().toLowerCase()
    let anyVisible = false

    this.itemTargets.forEach((item) => {
      const matches = !query || item.textContent.trim().toLowerCase().includes(query)
      item.classList.toggle("hidden", !matches)
      if (matches) anyVisible = true
    })

    this.groupTargets.forEach((group) => {
      const panel = group.querySelector('[data-sidebar-target~="groupPanel"]')
      const chevron = group.querySelector('[data-sidebar-target~="groupChevron"]')
      const groupMatches = [ ...panel.querySelectorAll('[data-sidebar-target~="item"]') ]
        .some((item) => !item.classList.contains("hidden"))

      if (query) {
        group.classList.toggle("hidden", !groupMatches)
        panel.hidden = !groupMatches
        chevron?.classList.toggle("rotate-180", groupMatches)
      } else {
        group.classList.remove("hidden")
      }
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = anyVisible
  }
}
