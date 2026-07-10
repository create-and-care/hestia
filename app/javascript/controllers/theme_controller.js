import { Controller } from "@hotwired/stimulus"

// Cycles light -> dark -> system, persisted in localStorage under "theme".
// The actual .dark class is applied by the inline anti-flash script in
// app/views/layouts/application.html.erb (runs before first paint); this
// controller keeps it in sync afterwards and reflects the active choice
// in its own icon/label state.
export default class extends Controller {
  static targets = [ "option" ]

  static ORDER = [ "light", "dark", "system" ]

  static LABELS = {
    light: "Thème actuel : clair. Cliquer pour changer de thème.",
    dark: "Thème actuel : sombre. Cliquer pour changer de thème.",
    system: "Thème actuel : système. Cliquer pour changer de thème."
  }

  connect() {
    this.media = window.matchMedia("(prefers-color-scheme: dark)")
    this.mediaListener = () => { if (this.current() === "system") this.apply() }
    this.media.addEventListener("change", this.mediaListener)
    this.render()
  }

  disconnect() {
    this.media.removeEventListener("change", this.mediaListener)
  }

  current() {
    return localStorage.getItem("theme") || "system"
  }

  cycle() {
    const next = this.constructor.ORDER[(this.constructor.ORDER.indexOf(this.current()) + 1) % 3]
    localStorage.setItem("theme", next)
    this.apply()
    this.render()
  }

  apply() {
    const theme = this.current()
    const isDark = theme === "dark" || (theme === "system" && this.media.matches)
    document.documentElement.classList.toggle("dark", isDark)
  }

  render() {
    const theme = this.current()
    this.optionTargets.forEach((el) => { el.hidden = el.dataset.theme !== theme })
    this.element.setAttribute("aria-label", this.constructor.LABELS[theme])
  }
}
