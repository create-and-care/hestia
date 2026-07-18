import { Controller } from "@hotwired/stimulus"

// Prefills the shopping-item name/rayon fields when a catalog product is
// picked from the "choose from catalog" combobox — a distinct path from
// free-text entry, sharing the same name/rayon fields either way. The
// combobox's option value is encoded as "id|rayon|name".
export default class extends Controller {
  static targets = [ "name", "rayon" ]

  pick(event) {
    const [ , rayon, name ] = event.detail.value.split("|")
    if (name) this.nameTarget.value = name
    if (rayon && this.hasRayonTarget) this.rayonTarget.value = rayon
  }
}
