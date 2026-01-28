import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hours", "minutes", "rate", "total"]

  connect() {
    this.update()
  }

  update() {
    const hours = this.numberValue(this.hoursTarget.value)
    const minutes = this.numberValue(this.minutesTarget.value)
    const rate = this.numberValue(this.rateTarget.value)

    const totalHours = hours + minutes / 60
    const total = totalHours * rate

    this.totalTarget.textContent = this.formatCurrency(total)
  }

  numberValue(value) {
    const parsed = parseFloat(value)
    return Number.isNaN(parsed) ? 0 : parsed
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-AU", {
      style: "currency",
      currency: "AUD"
    }).format(value)
  }
}
