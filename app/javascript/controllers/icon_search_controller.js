import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "item", "empty" ]

  filter() {
    const query = this.inputTarget.value.trim().toLowerCase()
    let visibleCount = 0

    this.itemTargets.forEach((item) => {
      const matches = item.dataset.name.includes(query)
      item.hidden = !matches
      if (matches) visibleCount++
    })

    this.emptyTarget.hidden = visibleCount > 0
  }
}
