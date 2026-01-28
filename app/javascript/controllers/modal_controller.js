import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close() {
    this.element.innerHTML = ""
  }

  backdrop(event) {
    if (event.target === event.currentTarget) {
      this.close()
    }
  }
}
