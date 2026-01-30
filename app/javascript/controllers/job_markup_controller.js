import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["jobSelect", "markup"]
  static values = { auto: Boolean }

  connect() {
    if (this.autoValue) {
      this.update()
    }
  }

  update() {
    if (!this.hasJobSelectTarget || !this.hasMarkupTarget) return
    const selected = this.jobSelectTarget.selectedOptions[0]
    if (!selected) return

    const value = selected.dataset.defaultMarkup
    if (value === undefined || value === null || value === "") return

    this.markupTarget.value = value
    this.markupTarget.dispatchEvent(new Event("input", { bubbles: true }))
  }
}
