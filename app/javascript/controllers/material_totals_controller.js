import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "quantity",
    "unitCost",
    "markup",
    "sellUnit",
    "total"
  ]

  connect() {
    this.update()
  }

  update() {
    const quantity = this.numberValue(this.quantityTarget.value)
    const unitCost = this.numberValue(this.unitCostTarget.value)
    const markup = this.numberValue(this.markupTarget.value)

    const sellUnit = unitCost * (1 + markup / 100)
    const total = sellUnit * quantity

    if (this.hasSellUnitTarget) {
      this.sellUnitTarget.textContent = this.formatCurrency(sellUnit)
    }
    if (this.hasTotalTarget) {
      this.totalTarget.textContent = this.formatCurrency(total)
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
