import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash" — relays a server-rendered flash
// message into a sonner toast (window "toast:show" event) instead of a
// static banner, then removes its own (invisible) element.
export default class extends Controller {
  static values = { message: String, variant: { type: String, default: "default" } }

  connect() {
    window.dispatchEvent(new CustomEvent("toast:show", { detail: { description: this.messageValue, variant: this.variantValue } }))
    this.element.remove()
  }
}
