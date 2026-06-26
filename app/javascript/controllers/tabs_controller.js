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

  render() {
    this.tabTargets.forEach((tab) => {
      const isActive = tab.dataset.value === this.activeValue
      tab.setAttribute("aria-selected", isActive)
      tab.classList.toggle("bg-tab-item-active", isActive)
      tab.classList.toggle("text-primary", isActive)
      tab.classList.toggle("text-secondary", !isActive)
    })
    this.panelTargets.forEach((panel) => {
      panel.hidden = panel.dataset.value !== this.activeValue
    })
  }
}
