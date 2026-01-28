require "test_helper"

class InvoiceLineItemTest < ActiveSupport::TestCase
  test "total cents is computed from quantity and unit price" do
    account = Account.create!(name: "Hammertime")
    customer = account.customers.create!(name: "Acme")
    job = account.jobs.create!(customer: customer, title: "Job", status: "active")
    invoice = account.invoices.create!(
      customer: customer,
      job: job,
      status: "draft",
      issued_on: Date.current,
      due_on: Date.current + 7
    )

    item = InvoiceLineItem.create!(
      account: account,
      invoice: invoice,
      item_type: "labour",
      description: "Labour",
      quantity: 2.5,
      unit_price_cents: 1234
    )

    assert_equal 3085, item.total_cents
  end
end
