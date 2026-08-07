import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Replaces the browser's confirm() for every `data: { turbo_confirm: "…" }` in
// the app. Turbo 8 lets a single function stand in for the native dialog, so
// the 59 call sites keep their existing markup and all of them get the design
// system's alert dialog instead of an unstyleable OS box.
//
// Mounted once per layout (shared/_confirm_dialog). The handler is installed on
// Turbo itself rather than on this element, so it has to survive the controller
// being torn down and rebuilt by a Turbo navigation — hence the module-level
// `current`, which always points at whichever instance is on the page now.
let current = null

export default class extends Controller {
  static targets = [ "dialog", "title", "message", "accept" ]

  connect() {
    current = this
    // Set once, and left in place: Turbo.config is global, and a page that
    // somehow renders without this dialog should fall back to the native
    // confirm rather than silently resolving every confirmation to true.
    Turbo.config.forms.confirm = (message) => {
      if (!current) return Promise.resolve(window.confirm(message))
      return current.ask(message)
    }
  }

  disconnect() {
    if (current === this) current = null
    this.#settle(false)
  }

  ask(message) {
    this.messageTarget.textContent = message || ""
    // No message means no second line to read; hiding it keeps the dialog from
    // showing an empty paragraph's worth of space under the title.
    this.messageTarget.hidden = !message
    this.dialogTarget.showModal()
    requestAnimationFrame(() => { this.dialogTarget.dataset.state = "open" })
    this.acceptTarget.focus()

    return new Promise((resolve) => { this.resolve = resolve })
  }

  accept() { this.#close(true) }
  cancel() { this.#close(false) }

  // Escape fires the native `cancel` event, which would close the dialog
  // immediately and skip the exit animation — route it through the same path
  // the buttons use, exactly as dialog_controller does.
  onCancel(event) {
    event.preventDefault()
    this.cancel()
  }

  onBackdrop(event) {
    if (event.target === this.dialogTarget) this.cancel()
  }

  // A dialog closed by any route we did not drive — a nested form submit, the
  // browser's own dismissal — must still settle the promise, or the submission
  // that is waiting on it hangs forever.
  onClose() {
    this.#settle(false)
  }

  #close(confirmed) {
    this.#settle(confirmed)
    this.dialogTarget.dataset.state = "closed"
    this.dialogTarget.addEventListener("animationend", () => this.dialogTarget.close(), { once: true })
  }

  #settle(confirmed) {
    if (!this.resolve) return

    const resolve = this.resolve
    this.resolve = null
    resolve(confirmed)
  }
}
