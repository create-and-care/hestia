import { Controller } from "@hotwired/stimulus"

// Sélectionner une enseigne du catalogue (CDC §10.5) pré-remplit le nom et le
// format de code ; l'utilisateur reste libre de les modifier ensuite.
export default class extends Controller {
  static targets = ["select", "name", "format"]

  apply() {
    const option = this.selectTarget.selectedOptions[0]
    if (!option || !option.dataset.name) return

    if (this.hasNameTarget) this.nameTarget.value = option.dataset.name
    if (this.hasFormatTarget) this.formatTarget.value = option.dataset.format
  }
}
