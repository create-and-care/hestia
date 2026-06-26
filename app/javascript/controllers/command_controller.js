import { Controller } from "@hotwired/stimulus"

// Filterable list used standalone (command palette) and embedded in combobox.
export default class extends Controller {
  static targets = [ "input", "item", "empty" ]

  filter() {
    const query = this.inputTarget.value.trim().toLowerCase()
    let visibleCount = 0

    this.itemTargets.forEach((item) => {
      const matches = item.textContent.trim().toLowerCase().includes(query)
      item.hidden = !matches
      if (matches) visibleCount++
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = visibleCount > 0
  }

  select(event) {
    this.dispatch("select", { detail: { value: event.currentTarget.dataset.value, label: event.currentTarget.textContent.trim() } })
  }
}
