require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  test "generates sequential invoice numbers per account" do
    account = Account.create!(name: "Hammertime")
    customer = account.customers.create!(name: "Acme")

    first = account.invoices.create!(
      customer: customer,
      status: "draft",
      issued_on: Date.current,
      due_on: Date.current + 7
    )

    second = account.invoices.create!(
      customer: customer,
      status: "draft",
      issued_on: Date.current,
      due_on: Date.current + 7
    )

    assert_equal "000001", first.invoice_number
    assert_equal "000002", second.invoice_number

    other_account = Account.create!(name: "Other")
    other_customer = other_account.customers.create!(name: "Other")
    other_invoice = other_account.invoices.create!(
      customer: other_customer,
      status: "draft",
      issued_on: Date.current,
      due_on: Date.current + 7
    )

    assert_equal "000001", other_invoice.invoice_number
  end

  test "subtotal and total sum line items" do
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

    InvoiceLineItem.create!(
      account: account,
      invoice: invoice,
      item_type: "labour",
      description: "Labour",
      quantity: 1,
      unit_price_cents: 10000
    )

    InvoiceLineItem.create!(
      account: account,
      invoice: invoice,
      item_type: "material",
      description: "Material",
      quantity: 2,
      unit_price_cents: 2500
    )

    assert_equal 15000, invoice.subtotal_cents
    assert_equal 15000, invoice.total_cents
  end
end
