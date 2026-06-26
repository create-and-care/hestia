import { Controller } from "@hotwired/stimulus"

const VARIANT_CLASSES = {
  default: "border-primary",
  success: "border-primary text-success",
  destructive: "border-destructive text-destructive"
}

// Mount once (e.g. in the layout) as <div data-controller="sonner">. Trigger toasts
// from anywhere with: window.dispatchEvent(new CustomEvent("toast:show", { detail: { title, description, variant } }))
export default class extends Controller {
  connect() {
    this.onShow = (event) => this.show(event.detail)
    window.addEventListener("toast:show", this.onShow)
  }

  disconnect() {
    window.removeEventListener("toast:show", this.onShow)
  }

  show({ title, description, variant = "default", duration = 4000 } = {}) {
    const toast = document.createElement("div")
    toast.dataset.state = "open"
    toast.className = `pointer-events-auto w-80 rounded-lg border bg-container p-4 shadow-lg
      data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:slide-in-from-bottom-2
      data-[state=closed]:animate-out data-[state=closed]:fade-out-0
      ${VARIANT_CLASSES[variant] || VARIANT_CLASSES.default}`

    if (title) {
      const titleEl = document.createElement("p")
      titleEl.className = "text-sm font-medium text-primary"
      titleEl.textContent = title
      toast.appendChild(titleEl)
    }

    if (description) {
      const descriptionEl = document.createElement("p")
      descriptionEl.className = "text-sm text-secondary mt-1"
      descriptionEl.textContent = description
      toast.appendChild(descriptionEl)
    }

    const dismiss = () => {
      toast.dataset.state = "closed"
      toast.addEventListener("animationend", () => toast.remove(), { once: true })
    }

    toast.addEventListener("click", dismiss)
    this.element.appendChild(toast)
    setTimeout(dismiss, duration)
  }
}
