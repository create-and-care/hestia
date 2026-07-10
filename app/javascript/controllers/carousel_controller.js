import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "track", "item", "dot", "status" ]

  connect() {
    this.update()
    this.trackTarget.addEventListener("scroll", this.onScroll)
  }

  disconnect() {
    this.trackTarget.removeEventListener("scroll", this.onScroll)
  }

  next() { this.scrollToIndex(this.currentIndex + 1) }
  previous() { this.scrollToIndex(this.currentIndex - 1) }

  goTo(event) {
    this.scrollToIndex(Number(event.currentTarget.dataset.index))
  }

  scrollToIndex(index) {
    const clamped = Math.max(0, Math.min(index, this.itemTargets.length - 1))
    this.itemTargets[clamped]?.scrollIntoView({ behavior: "smooth", inline: "start", block: "nearest" })
  }

  onScroll = () => { this.update() }

  update() {
    const trackLeft = this.trackTarget.scrollLeft
    this.currentIndex = this.itemTargets.findIndex((item) => item.offsetLeft >= trackLeft - 4)

    this.dotTargets.forEach((dot, index) => {
      const isCurrent = index === this.currentIndex
      dot.classList.toggle("bg-button-primary", isCurrent)
      dot.setAttribute("aria-current", String(isCurrent))
    })

    if (this.hasStatusTarget && this.itemTargets.length) {
      this.statusTarget.textContent = `Diapositive ${this.currentIndex + 1} sur ${this.itemTargets.length}`
    }
  }
}
