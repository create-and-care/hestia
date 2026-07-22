import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Drag-and-drop reordering. Persists the new order via a PATCH to the given
// URL, sending the ordered list of ids.
export default class extends Controller {
  static values = { url: String, errorMessage: String }

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

  async persist() {
    const ids = Array.from(this.element.children)
      .map((el) => el.dataset.sortableId)
      .filter(Boolean)

    const token = document.querySelector("meta[name='csrf-token']")?.content

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": token,
          "Accept": "application/json"
        },
        body: JSON.stringify({ ids })
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
    } catch {
      // A rejected PATCH used to fail completely silently, resetting the order on the next
      // reload with no explanation — surface it instead when the view opts in.
      if (this.errorMessageValue) {
        window.dispatchEvent(new CustomEvent("toast:show", { detail: { title: this.errorMessageValue, variant: "destructive" } }))
      }
    }
  }
}
