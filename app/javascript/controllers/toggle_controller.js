import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    const button = event.currentTarget
    const pressed = button.getAttribute("aria-pressed") === "true"
    button.setAttribute("aria-pressed", String(!pressed))
  }
}
