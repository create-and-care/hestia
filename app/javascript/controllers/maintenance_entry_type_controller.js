import { Controller } from "@hotwired/stimulus"

// Toggles between a predefined maintenance-type <select> and a free-text fallback shown when
// "Other" is chosen. Both fields share the same submitted param name, so only one may actually
// be enabled at submit time — the select stays interactive at all times (so switching back off
// "Other" is always possible); the swap only happens right before the form serializes.
export default class extends Controller {
  static targets = [ "select", "custom" ]

  connect() {
    this.sync()
  }

  sync() {
    const isOther = this.selectTarget.value === "other"
    this.customTarget.classList.toggle("hidden", !isOther)
    this.customTarget.required = isOther
  }

  beforeSubmit() {
    const isOther = this.selectTarget.value === "other"
    this.selectTarget.disabled = isOther
    this.customTarget.disabled = !isOther
  }
}
