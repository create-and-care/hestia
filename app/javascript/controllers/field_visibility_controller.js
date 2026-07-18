import { Controller } from "@hotwired/stimulus"

// Shows/hides target fields based on whether the trigger's current value is
// in this controller's showWhen list. Used to hide the gift list recipient
// selector when the perspective is "receive" (no recipient in that case).
export default class extends Controller {
  static targets = [ "trigger", "field" ]
  static values = { showWhen: Array }

  connect() {
    this.refresh()
  }

  refresh() {
    const visible = this.showWhenValue.includes(this.triggerTarget.value)
    this.fieldTargets.forEach((field) => field.classList.toggle("hidden", !visible))
  }
}
