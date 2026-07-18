import { Controller } from "@hotwired/stimulus"

// Debounces submitting the enclosing form as the user types, so search-as-you-type works
// without waiting for Enter or a full page reload. Reusable on any GET form with a text/search
// input wired with data-action="input->debounced-search#submit".
export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } }

  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.element.requestSubmit(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
