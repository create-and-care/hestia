import { Controller } from "@hotwired/stimulus"

// Looks up a product by barcode (household catalog, then Open Food Facts)
// and pre-fills the form fields (Spec §9.1, §9.4, §16). Manual entry is
// always still possible if nothing is found.
export default class extends Controller {
  static targets = ["barcode", "name", "rayon", "status"]
  static values = {
    url: String,
    searchingText: String,
    notFoundText: String,
    unavailableText: String,
    foundText: String
  }

  async lookup() {
    const barcode = this.barcodeTarget.value.trim()
    if (!barcode) return

    this.setStatus(this.searchingTextValue)

    try {
      const response = await fetch(`${this.urlValue}?barcode=${encodeURIComponent(barcode)}`, {
        headers: { Accept: "application/json" }
      })

      if (!response.ok) {
        this.setStatus(this.notFoundTextValue)
        return
      }

      const product = await response.json()
      if (this.hasNameTarget && product.name) this.nameTarget.value = product.name
      if (this.hasRayonTarget && product.rayon) this.rayonTarget.value = product.rayon
      this.setStatus(`${this.foundTextValue} ${product.name}`)
    } catch {
      this.setStatus(this.unavailableTextValue)
    }
  }

  setStatus(message) {
    if (this.hasStatusTarget) this.statusTarget.textContent = message
  }
}
