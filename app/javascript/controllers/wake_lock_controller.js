import { Controller } from "@hotwired/stimulus"

// Keeps the screen on for as long as cook mode is open (Spec §9.5) — the
// Wake Lock API silently releases itself whenever the tab is hidden, so we
// re-acquire it on visibilitychange rather than only once on connect.
export default class extends Controller {
  connect() {
    this.request()
    this.onVisibilityChange = () => {
      if (document.visibilityState === "visible") this.request()
    }
    document.addEventListener("visibilitychange", this.onVisibilityChange)
  }

  async request() {
    if (!("wakeLock" in navigator)) return

    try {
      this.wakeLock = await navigator.wakeLock.request("screen")
    } catch {
      // Unsupported in this context (e.g. backgrounded tab, low battery) — cook
      // mode still works, it just won't keep the screen awake this time.
    }
  }

  disconnect() {
    document.removeEventListener("visibilitychange", this.onVisibilityChange)
    this.wakeLock?.release()
    this.wakeLock = null
  }
}
