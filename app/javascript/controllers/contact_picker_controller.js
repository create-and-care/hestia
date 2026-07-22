import { Controller } from "@hotwired/stimulus"

// Best-effort mobile contact import via the Contact Picker API (Chrome/Android only as of
// writing — no desktop or iOS Safari support). The button removes itself when the API is
// absent, since a button that silently does nothing would be worse than not showing it.
export default class extends Controller {
  static targets = [ "name", "phone", "email", "button" ]

  connect() {
    if (!("contacts" in navigator && "ContactsManager" in window)) {
      this.buttonTarget?.remove()
    }
  }

  async pick() {
    try {
      const [ contact ] = await navigator.contacts.select([ "name", "tel", "email" ], { multiple: false })
      if (!contact) return

      if (this.hasNameTarget && contact.name?.[0]) this.nameTarget.value = contact.name[0]
      if (this.hasPhoneTarget && contact.tel?.[0]) this.phoneTarget.value = contact.tel[0]
      if (this.hasEmailTarget && contact.email?.[0]) this.emailTarget.value = contact.email[0]
    } catch {
      // The user cancelled the picker or denied permission — nothing to do.
    }
  }
}
