import { Controller } from "@hotwired/stimulus"

// Wraps a native <dialog> element — used by dialog, alert-dialog, sheet and drawer.
// [data-state] drives both the ::backdrop fade (application.tailwind.css) and the
// content's animate-in/out + zoom/slide utility classes set on the dialog itself.
export default class extends Controller {
  static targets = [ "dialog" ]

  open() {
    this.dialogTarget.showModal()
    requestAnimationFrame(() => { this.dialogTarget.dataset.state = "open" })
  }

  close() {
    this.dialogTarget.dataset.state = "closed"
    this.dialogTarget.addEventListener("animationend", () => this.dialogTarget.close(), { once: true })
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }
}
