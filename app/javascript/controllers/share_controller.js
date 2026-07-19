import { Controller } from "@hotwired/stimulus"

// Progressive enhancement: markup is a plain mailto: link (works with no JS and
// no Web Share support); when the Web Share API is available we intercept the
// click and hand off to the native OS share sheet instead.
export default class extends Controller {
  static values = { url: String, title: String }

  share(event) {
    if (!navigator.share) return

    event.preventDefault()
    navigator.share({ title: this.titleValue, url: this.urlValue }).catch(() => {})
  }
}
