import { Controller } from "@hotwired/stimulus"

// Left/Right-arrow roving focus between the top-level menubar triggers.
// Up/Down navigation within an already-open menu is handled by the composed
// dropdown-menu controller on each entry (see dropdown_menu_controller.js).
export default class extends Controller {
  static targets = [ "item" ]

  onKeydown(event) {
    if (event.key !== "ArrowRight" && event.key !== "ArrowLeft") return

    const items = this.itemTargets
    const currentIndex = items.indexOf(event.currentTarget)
    if (currentIndex === -1) return

    event.preventDefault()
    const delta = event.key === "ArrowRight" ? 1 : -1
    items[(currentIndex + delta + items.length) % items.length]?.focus()
  }
}
