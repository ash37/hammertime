require "test_helper"

class TimesheetEntryTest < ActiveSupport::TestCase
  test "hours and total cents calculate correctly" do
    account = Account.create!(name: "Hammertime")
    user = account.users.create!(
      email: "staff@example.com",
      name: "Staff",
      password: "password123",
      role: "staff",
      hourly_rate_cents: 6000
    )
    customer = account.customers.create!(name: "Acme")
    job = account.jobs.create!(customer: customer, title: "Job", status: "active")

    entry = TimesheetEntry.create!(
      account: account,
      user: user,
      job: job,
      work_date: Date.current,
      minutes: 90,
      hourly_rate_cents: 6000
    )

    assert_in_delta 1.5, entry.hours, 0.001
    assert_equal 9000, entry.total_cents
  end

  test "billed? is true when invoice line item exists" do
    account = Account.create!(name: "Hammertime")
    user = account.users.create!(
      email: "staff@example.com",
      name: "Staff",
      password: "password123",
      role: "staff",
      hourly_rate_cents: 6000
    )
    customer = account.customers.create!(name: "Acme")
    job = account.jobs.create!(customer: customer, title: "Job", status: "active")

    entry = TimesheetEntry.create!(
      account: account,
      user: user,
      job: job,
      work_date: Date.current,
      minutes: 60,
      hourly_rate_cents: 6000
    )

    assert_not entry.billed?

    invoice = account.invoices.create!(
      customer: customer,
      job: job,
      status: "draft",
      issued_on: Date.current,
      due_on: Date.current + 7
    )

    InvoiceLineItem.create!(
      account: account,
      invoice: invoice,
      source: entry,
      item_type: "labour",
      description: "Labour",
      quantity: entry.hours,
      unit_price_cents: entry.hourly_rate_cents
    )

    assert entry.reload.billed?
  end
end
