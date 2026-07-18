import { Controller } from "@hotwired/stimulus"

// Fills the target textarea by voice using the browser's SpeechRecognition API. Only Chrome,
// Edge and Safari expose it (via the vendor-prefixed webkitSpeechRecognition) — unsupported
// browsers just don't get the mic button wired up, since a button that silently does nothing
// would be worse than not showing it at all.
export default class extends Controller {
  static targets = [ "output", "button" ]

  connect() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    if (!SpeechRecognition) {
      this.buttonTarget?.remove()
      return
    }

    this.recognition = new SpeechRecognition()
    this.recognition.lang = document.documentElement.lang || "fr-FR"
    this.recognition.interimResults = false

    this.recognition.onresult = (event) => {
      const transcript = Array.from(event.results).map((result) => result[0].transcript).join(" ")
      this.outputTarget.value = [ this.outputTarget.value, transcript ].filter(Boolean).join(" ")
      this.outputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    }
    this.recognition.onend = () => this.buttonTarget.classList.remove("animate-pulse")
  }

  toggle() {
    this.buttonTarget.classList.add("animate-pulse")
    this.recognition.start()
  }

  disconnect() {
    this.recognition?.abort()
  }
}
