import { Controller } from "@hotwired/stimulus"

// Place search via Nominatim/OpenStreetMap (Spec §10.3, §16) to pre-fill
// an address. Manual entry is always still possible (confidential addresses).
export default class extends Controller {
  static targets = ["query", "results", "name", "fullAddress", "latitude", "longitude"]
  static values = {
    url: String,
    searchingText: String,
    noResultsText: String,
    unavailableText: String
  }

  async search() {
    const query = this.queryTarget.value.trim()
    if (!query) return

    this.resultsTarget.innerHTML = `<p class="px-2 py-1 text-xs text-gray-400">${this.searchingTextValue}</p>`

    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
        headers: { Accept: "application/json" }
      })
      const results = response.ok ? await response.json() : []

      if (results.length === 0) {
        this.resultsTarget.innerHTML = `<p class="px-2 py-1 text-xs text-gray-400">${this.noResultsTextValue}</p>`
        return
      }

      this.resultsTarget.innerHTML = ""
      results.forEach((result, index) => {
        const button = document.createElement("button")
        button.type = "button"
        button.className = "block w-full rounded px-2 py-1 text-left text-sm hover:bg-gray-50"
        button.textContent = result.full_address
        button.dataset.action = "click->geocode-lookup#select"
        button.dataset.index = index
        this.resultsTarget.appendChild(button)
        this.results = this.results || []
      })
      this.results = results
    } catch (error) {
      this.resultsTarget.innerHTML = `<p class="px-2 py-1 text-xs text-gray-400">${this.unavailableTextValue}</p>`
    }
  }

  select(event) {
    const result = this.results[event.currentTarget.dataset.index]
    if (!result) return

    if (this.hasNameTarget) this.nameTarget.value = result.name || ""
    if (this.hasFullAddressTarget) this.fullAddressTarget.value = result.full_address || ""
    if (this.hasLatitudeTarget) this.latitudeTarget.value = result.latitude || ""
    if (this.hasLongitudeTarget) this.longitudeTarget.value = result.longitude || ""
    this.resultsTarget.innerHTML = ""
  }
}
