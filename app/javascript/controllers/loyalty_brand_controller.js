import { Controller } from "@hotwired/stimulus"

// Selecting a brand from the catalog (Spec §10.5) pre-fills the name and
// code format; the user is still free to edit them afterward.
export default class extends Controller {
  static targets = ["select", "name", "format"]

  apply() {
    const option = this.selectTarget.selectedOptions[0]
    if (!option || !option.dataset.name) return

    if (this.hasNameTarget) this.nameTarget.value = option.dataset.name
    if (this.hasFormatTarget) this.formatTarget.value = option.dataset.format
  }
}
