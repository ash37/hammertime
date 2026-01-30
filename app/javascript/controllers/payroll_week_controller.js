import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "example"]

  connect() {
    this.update()
  }

  update() {
    if (!this.hasSelectTarget || !this.hasExampleTarget) return

    const value = parseInt(this.selectTarget.value, 10)
    if (Number.isNaN(value)) return

    const labels = {
      0: "SUN",
      1: "MON",
      2: "TUE",
      3: "WED",
      4: "THU",
      5: "FRI",
      6: "SAT"
    }

    const start = labels[value]
    const end = labels[(value + 6) % 7]
    if (start && end) {
      this.exampleTarget.textContent = `${start} - ${end}`
    }
  }
}
