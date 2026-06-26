import { Controller } from "@hotwired/stimulus"

const MONTH_NAMES = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]
const WEEKDAYS = [ "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" ]

export default class extends Controller {
  static targets = [ "label", "grid", "input" ]
  static values = { year: Number, month: Number, selected: String }

  connect() {
    const today = new Date()
    this.yearValue ||= today.getFullYear()
    this.monthValue ||= today.getMonth()
    this.render()
  }

  next() { this.shiftMonth(1) }
  previous() { this.shiftMonth(-1) }

  shiftMonth(delta) {
    const date = new Date(this.yearValue, this.monthValue + delta, 1)
    this.yearValue = date.getFullYear()
    this.monthValue = date.getMonth()
    this.render()
  }

  select(event) {
    this.selectedValue = event.currentTarget.dataset.date
    if (this.hasInputTarget) this.inputTarget.value = this.selectedValue
    this.dispatch("select", { detail: { date: this.selectedValue } })
    this.render()
  }

  render() {
    this.labelTarget.textContent = `${MONTH_NAMES[this.monthValue]} ${this.yearValue}`

    const firstWeekday = new Date(this.yearValue, this.monthValue, 1).getDay()
    const daysInMonth = new Date(this.yearValue, this.monthValue + 1, 0).getDate()
    const todayKey = new Date().toDateString()

    const cells = WEEKDAYS.map((day) =>
      `<div class="h-8 flex items-center justify-center text-xs font-medium text-secondary">${day}</div>`
    )

    for (let i = 0; i < firstWeekday; i++) cells.push(`<div></div>`)

    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(this.yearValue, this.monthValue, day)
      const dateKey = date.toISOString().slice(0, 10)
      const isSelected = dateKey === this.selectedValue
      const isToday = date.toDateString() === todayKey

      cells.push(`
        <button type="button" data-action="click->calendar#select" data-date="${dateKey}"
          class="h-8 w-8 rounded-md text-sm transition-colors ${isSelected ? "bg-button-primary text-inverse" : "text-primary hover:bg-surface-hover"} ${isToday && !isSelected ? "font-semibold" : ""}">
          ${day}
        </button>
      `)
    }

    this.gridTarget.innerHTML = `<div class="grid grid-cols-7 gap-1">${cells.join("")}</div>`
  }
}
