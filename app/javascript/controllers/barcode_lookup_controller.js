import { Controller } from "@hotwired/stimulus"

// Looks up a product by barcode (household catalog, then Open Food Facts)
// and pre-fills the form fields (Spec §9.1, §9.4, §16). Manual entry is
// always still possible if nothing is found.
export default class extends Controller {
  static targets = ["barcode", "name", "rayon", "status"]
  static values = { url: String }

  async lookup() {
    const barcode = this.barcodeTarget.value.trim()
    if (!barcode) return

    this.setStatus("Recherche…")

    try {
      const response = await fetch(`${this.urlValue}?barcode=${encodeURIComponent(barcode)}`, {
        headers: { Accept: "application/json" }
      })

      if (!response.ok) {
        this.setStatus("Produit non trouvé — saisie manuelle.")
        return
      }

      const product = await response.json()
      if (this.hasNameTarget && product.name) this.nameTarget.value = product.name
      if (this.hasRayonTarget && product.rayon) this.rayonTarget.value = product.rayon
      this.setStatus(`Trouvé : ${product.name}`)
    } catch (error) {
      this.setStatus("Recherche indisponible — saisie manuelle.")
    }
  }

  setStatus(message) {
    if (this.hasStatusTarget) this.statusTarget.textContent = message
  }
}
