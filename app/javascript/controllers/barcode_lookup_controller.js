import { Controller } from "@hotwired/stimulus"

// Recherche un produit par code-barres (catalogue du foyer, puis Open Food Facts)
// et pré-remplit les champs du formulaire (CDC §9.1, §9.4, §16). La saisie
// manuelle reste toujours possible si rien n'est trouvé.
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
