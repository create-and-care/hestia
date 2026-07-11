import { Controller } from "@hotwired/stimulus"

// Wraps a native <dialog> element — used by dialog, alert-dialog, sheet and drawer.
// [data-state] drives both the ::backdrop fade (application.tailwind.css) and the
// content's animate-in/out + zoom/slide utility classes set on the dialog itself.
export default class extends Controller {
  static targets = [ "dialog" ]

  // Also bound to `keydown@window` by the search palette (⌘K/Ctrl+K) — every
  // other caller triggers this via a plain click, so the guard below only
  // engages for a keydown-sourced event and leaves click behavior untouched.
  open(event) {
    if (event?.type === "keydown") {
      const isShortcut = (event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k"
      if (!isShortcut || this.dialogTarget.open) return
      event.preventDefault() // browsers default Ctrl/Cmd+K to focusing the address bar
    }

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

  // Escape fires the dialog's native `cancel` event, which by default calls
  // the browser's own immediate .close() — bypassing the state transition
  // above entirely and skipping the exit animation. Intercept it and route
  // through the same close() the click handlers use.
  onCancel(event) {
    event.preventDefault()
    this.close()
  }
}
