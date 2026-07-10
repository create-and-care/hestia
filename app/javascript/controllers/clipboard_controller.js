import { Controller } from "@hotwired/stimulus"

// Generic copy-to-clipboard: reads data-clipboard-text-value (or, failing
// that, the trimmed textContent of the first [data-clipboard-target="source"]
// found inside the controller element) and confirms via the Sonner toast.
export default class extends Controller {
  static targets = [ "source" ]
  static values = { text: String, message: { type: String, default: "Copié dans le presse-papiers" } }

  async copy() {
    const text = this.textValue || (this.hasSourceTarget ? this.sourceTarget.textContent.trim() : "")
    if (!text) return

    await navigator.clipboard.writeText(text)
    window.dispatchEvent(new CustomEvent("toast:show", { detail: { title: this.messageValue, variant: "success" } }))
  }
}
