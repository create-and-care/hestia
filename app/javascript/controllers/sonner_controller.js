import { Controller } from "@hotwired/stimulus"

// Variant is carried by the status dot, not a coloured border/text — a
// coloured card reads as alarming even for routine confirmations.
const DOT_CLASSES = {
  default: "bg-subdued",
  success: "bg-success",
  destructive: "bg-destructive"
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
    toast.className = `pointer-events-auto flex min-w-[280px] items-start gap-2.5 rounded-lg bg-container py-3 px-4 shadow-border-lg
      data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:slide-in-from-bottom-2
      data-[state=closed]:animate-out data-[state=closed]:fade-out-0`

    const dot = document.createElement("span")
    dot.className = `mt-1.5 size-2 shrink-0 rounded-full ${DOT_CLASSES[variant] || DOT_CLASSES.default}`
    toast.appendChild(dot)

    const stack = document.createElement("div")
    stack.className = "flex flex-col min-w-0"

    if (title) {
      const titleEl = document.createElement("p")
      titleEl.className = "text-sm font-medium text-primary"
      titleEl.textContent = title
      stack.appendChild(titleEl)
    }

    if (description) {
      const descriptionEl = document.createElement("p")
      descriptionEl.className = "text-sm text-secondary mt-1"
      descriptionEl.textContent = description
      stack.appendChild(descriptionEl)
    }

    toast.appendChild(stack)

    const dismiss = () => {
      toast.dataset.state = "closed"
      toast.addEventListener("animationend", () => toast.remove(), { once: true })
    }

    toast.addEventListener("click", dismiss)
    this.element.appendChild(toast)
    setTimeout(dismiss, duration)
  }
}
