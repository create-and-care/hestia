import { Controller } from "@hotwired/stimulus"

// Lets a full-screen view (e.g. cook mode) be dismissed with the Escape key,
// in addition to its visible exit link/button.
export default class extends Controller {
  static targets = ["link"]

  exit() {
    this.linkTarget.click()
  }
}
