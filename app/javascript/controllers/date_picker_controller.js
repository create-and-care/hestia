import { Controller } from "@hotwired/stimulus"

// Formats the date picked in the composed Calendar (see calendar_controller.js's
// calendar:select event) into the trigger button's label.
export default class extends Controller {
  static targets = [ "label" ]

  select(event) {
    const date = new Date(`${event.detail.date}T00:00:00`)
    this.labelTarget.textContent = date.toLocaleDateString("fr-FR", { day: "numeric", month: "long", year: "numeric" })
  }
}
