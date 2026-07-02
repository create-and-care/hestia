import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Réorganisation par glisser-déposer. Persiste le nouvel ordre en PATCH sur l'URL
// fournie, en envoyant la liste ordonnée des identifiants.
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      handle: "[data-sortable-handle]",
      animation: 150,
      onEnd: () => this.persist()
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }

  persist() {
    const ids = Array.from(this.element.children)
      .map((el) => el.dataset.sortableId)
      .filter(Boolean)

    const token = document.querySelector("meta[name='csrf-token']")?.content

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "application/json"
      },
      body: JSON.stringify({ ids })
    })
  }
}
