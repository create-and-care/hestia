import { Controller } from "@hotwired/stimulus"

// Client-side sort + filter + pagination for Ui::DataTableComponent. Rows are
// the source of truth (read fresh each render); sorting reorders the actual
// <tr> nodes so cell markup (badges, links…) survives untouched.
export default class extends Controller {
  static targets = [ "filterInput", "header", "arrow", "body", "row", "pageLabel", "prevButton", "nextButton" ]
  static values = { pageSize: Number, page: { type: Number, default: 0 }, sortIndex: { type: Number, default: -1 }, sortDir: { type: String, default: "asc" } }

  connect() {
    this.render()
  }

  sort(event) {
    const index = Number(event.currentTarget.dataset.index)
    if (this.sortIndexValue === index) {
      this.sortDirValue = this.sortDirValue === "asc" ? "desc" : "asc"
    } else {
      this.sortIndexValue = index
      this.sortDirValue = "asc"
    }
    this.pageValue = 0
    this.render()
  }

  filter() {
    this.pageValue = 0
    this.render()
  }

  next() {
    this.pageValue += 1
    this.render()
  }

  previous() {
    this.pageValue -= 1
    this.render()
  }

  cellValue(row, index) {
    return row.children[index]?.textContent.trim() ?? ""
  }

  compareValues(a, b) {
    const numericA = parseFloat(a.replace(/[^0-9.,-]/g, "").replace(",", "."))
    const numericB = parseFloat(b.replace(/[^0-9.,-]/g, "").replace(",", "."))
    const bothNumeric = !Number.isNaN(numericA) && !Number.isNaN(numericB)
    return bothNumeric ? numericA - numericB : a.localeCompare(b)
  }

  render() {
    const query = this.filterInputTarget.value.trim().toLowerCase()

    let rows = this.rowTargets.filter((row) => row.textContent.toLowerCase().includes(query))

    if (this.sortIndexValue >= 0) {
      const direction = this.sortDirValue === "asc" ? 1 : -1
      rows = rows.sort((a, b) =>
        direction * this.compareValues(this.cellValue(a, this.sortIndexValue), this.cellValue(b, this.sortIndexValue))
      )
    }

    const pageCount = Math.max(1, Math.ceil(rows.length / this.pageSizeValue))
    this.pageValue = Math.min(this.pageValue, pageCount - 1)

    const start = this.pageValue * this.pageSizeValue

    this.rowTargets.forEach((row) => { row.hidden = true })
    rows.slice(start, start + this.pageSizeValue).forEach((row) => {
      row.hidden = false
      this.bodyTarget.appendChild(row)
    })

    this.pageLabelTarget.textContent = rows.length === 0
      ? "Aucun résultat"
      : `Page ${this.pageValue + 1} / ${pageCount} · ${rows.length} résultat${rows.length > 1 ? "s" : ""}`

    this.prevButtonTarget.disabled = this.pageValue === 0
    this.nextButtonTarget.disabled = this.pageValue >= pageCount - 1

    this.arrowTargets.forEach((arrow) => {
      const index = Number(arrow.dataset.index)
      arrow.textContent = index === this.sortIndexValue ? (this.sortDirValue === "asc" ? "↑" : "↓") : ""
    })
  }
}
