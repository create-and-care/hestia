import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "tab", "panel" ]
  static values = { active: String }

  connect() {
    this.activeValue ||= this.tabTargets[0]?.dataset.value
    this.render()
  }

  select(event) {
    this.activeValue = event.currentTarget.dataset.value
    this.render()
  }

  onKeydown(event) {
    const tabs = this.tabTargets
    const currentIndex = tabs.indexOf(event.currentTarget)
    if (currentIndex === -1) return

    let nextIndex
    if (event.key === "ArrowRight") nextIndex = (currentIndex + 1) % tabs.length
    else if (event.key === "ArrowLeft") nextIndex = (currentIndex - 1 + tabs.length) % tabs.length
    else if (event.key === "Home") nextIndex = 0
    else if (event.key === "End") nextIndex = tabs.length - 1
    else return

    event.preventDefault()
    const nextTab = tabs[nextIndex]
    this.activeValue = nextTab.dataset.value
    this.render()
    nextTab.focus()
  }

  render() {
    this.tabTargets.forEach((tab) => {
      const isActive = tab.dataset.value === this.activeValue
      tab.setAttribute("aria-selected", isActive)
      tab.setAttribute("tabindex", isActive ? "0" : "-1")
      tab.classList.toggle("bg-tab-item-active", isActive)
      tab.classList.toggle("text-primary", isActive)
      tab.classList.toggle("text-secondary", !isActive)
    })
    this.panelTargets.forEach((panel) => {
      panel.hidden = panel.dataset.value !== this.activeValue
    })
  }
}
