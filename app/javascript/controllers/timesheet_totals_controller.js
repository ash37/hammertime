import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "hours",
    "minutes",
    "userSelect",
    "billingRate",
    "hourlyCost",
    "billTotal",
    "costTotal"
  ]

  static values = {
    billingRate: Number,
    hourlyCost: Number
  }

  connect() {
    this.update()
  }

  update() {
    const hours = this.numberValue(this.hoursTarget.value)
    const minutes = this.numberValue(this.minutesTarget.value)
    const totalHours = hours + minutes / 60

    const { billingRate, hourlyCost } = this.currentRates()

    if (this.hasBillingRateTarget) {
      this.billingRateTarget.textContent = this.formatCurrency(billingRate)
    }
    if (this.hasBillTotalTarget) {
      this.billTotalTarget.textContent = this.formatCurrency(totalHours * billingRate)
    }

    if (this.hasHourlyCostTarget) {
      this.hourlyCostTarget.textContent = this.formatCurrency(hourlyCost)
    }
    if (this.hasCostTotalTarget) {
      this.costTotalTarget.textContent = this.formatCurrency(totalHours * hourlyCost)
    }
  }

  currentRates() {
    if (this.hasUserSelectTarget) {
      const selected = this.userSelectTarget.selectedOptions[0]
      const billingRate = this.numberValue(selected?.dataset?.billingRate)
      const hourlyCost = this.numberValue(selected?.dataset?.hourlyCost)
      return { billingRate, hourlyCost }
    }

    return {
      billingRate: this.billingRateValue || 0,
      hourlyCost: this.hourlyCostValue || 0
    }
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
