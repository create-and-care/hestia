import { Controller } from "@hotwired/stimulus"

// Keeps a message thread pinned to the bottom as content streams in, unless
// the reader has scrolled up to review history — then it surfaces a "new
// messages" button instead of yanking their scroll position.
export default class extends Controller {
  static targets = [ "viewport", "jumpButton" ]

  connect() {
    this.scrollToBottom()
    this.observer = new MutationObserver(() => {
      if (this.isNearBottom()) this.scrollToBottom()
      else this.jumpButtonTarget.hidden = false
    })
    this.observer.observe(this.viewportTarget, { childList: true, subtree: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  handleScroll() {
    this.jumpButtonTarget.hidden = this.isNearBottom()
  }

  isNearBottom() {
    const el = this.viewportTarget
    return el.scrollHeight - el.scrollTop - el.clientHeight < 48
  }

  scrollToBottom() {
    this.viewportTarget.scrollTop = this.viewportTarget.scrollHeight
    this.jumpButtonTarget.hidden = true
  }
}
