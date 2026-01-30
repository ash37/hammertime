import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["customerSelect", "jobSelect"]
  static values = { jobs: Array }

  connect() {
    this.update()
  }

  update() {
    if (!this.hasCustomerSelectTarget || !this.hasJobSelectTarget) return

    const customerId = this.customerSelectTarget.value
    const existingValue = this.jobSelectTarget.value || this.jobSelectTarget.dataset.currentValue
    const placeholder = this.jobSelectTarget.dataset.placeholder || "Unassigned"

    while (this.jobSelectTarget.options.length > 0) {
      this.jobSelectTarget.remove(0)
    }

    const blankOption = new Option(placeholder, "")
    this.jobSelectTarget.add(blankOption)

    if (!customerId) return

    const matchingJobs = this.jobsValue.filter(
      (job) => String(job.customer_id) === String(customerId)
    )

    matchingJobs.forEach((job) => {
      const option = new Option(job.title, job.id)
      this.jobSelectTarget.add(option)
    })

    const stillExists = matchingJobs.some((job) => String(job.id) === String(existingValue))
    if (stillExists) {
      this.jobSelectTarget.value = existingValue
    }
  }
}
