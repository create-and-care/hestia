import { Controller } from "@hotwired/stimulus"

// Generic "remove this element from the page" controller — for content that
// must not linger once acknowledged (e.g. Ui::CelebrationMoment), as opposed
// to flash_controller's toasts, which auto-dismiss on a timer.
export default class extends Controller {
  dismiss() {
    this.element.remove()
  }
}
