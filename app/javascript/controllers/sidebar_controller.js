import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "panel" ]
  static classes = [ "collapsed" ]

  connect() {
    if (localStorage.getItem("sidebar:collapsed") === "true") this.collapse()
  }

  toggle() {
    this.panelTarget.classList.contains(this.collapsedClass) ? this.expand() : this.collapse()
  }

  collapse() {
    this.panelTarget.classList.add(this.collapsedClass)
    localStorage.setItem("sidebar:collapsed", "true")
  }

  expand() {
    this.panelTarget.classList.remove(this.collapsedClass)
    localStorage.setItem("sidebar:collapsed", "false")
  }
}
