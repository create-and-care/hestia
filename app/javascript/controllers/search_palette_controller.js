import { Controller } from "@hotwired/stimulus"

// Debounced auto-submit + keyboard nav for the global search palette. Unlike
// command_controller#filter (a pure client-side substring match over a
// static list), results here are re-rendered server-side on every keystroke
// via the "global_search_results" turbo-frame, so there's nothing to filter
// client-side — this controller only debounces the round-trip and lets
// Arrow/Enter/Escape drive the (real <a href>) result links.
export default class extends Controller {
  static targets = [ "input", "item" ]
  static values = { delay: { type: Number, default: 250 } }

  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.element.querySelector("form").requestSubmit(), this.delayValue)
  }

  onKeydown(event) {
    if (event.key === "ArrowDown") { event.preventDefault(); this.moveActive(1); return }
    if (event.key === "ArrowUp") { event.preventDefault(); this.moveActive(-1); return }
    if (event.key === "Enter") { event.preventDefault(); clearTimeout(this.timeout); this.activeItem?.click(); return }

    if (event.key === "Escape" && this.inputTarget.value) {
      event.stopPropagation()
      this.inputTarget.value = ""
      this.submit()
    }
    // Escape on an already-empty input isn't stopped here, so it bubbles up
    // to the ancestor <dialog>'s native `cancel` handling (dialog_controller#onCancel).
  }

  moveActive(delta) {
    const items = this.itemTargets
    if (!items.length) return

    const currentIndex = items.indexOf(this.activeItem)
    const nextIndex = (currentIndex + delta + items.length) % items.length
    this.setActive(items[nextIndex])
  }

  setActive(item) {
    this.itemTargets.forEach((i) => {
      i.setAttribute("aria-selected", "false")
      i.classList.remove("bg-surface-hover")
    })

    this.activeItem = item || null

    if (item) {
      item.setAttribute("aria-selected", "true")
      item.classList.add("bg-surface-hover")
    }

    this.inputTarget.setAttribute("aria-activedescendant", item?.id || "")
  }

  // Highlight the first result whenever the turbo-frame reloads (Turbo swaps
  // its contents in place, so this listens for the frame's own load event
  // rather than a Stimulus targetConnected callback).
  onFrameLoad() {
    this.setActive(this.itemTargets[0])
  }
}
