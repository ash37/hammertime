require "test_helper"

class MaterialPurchaseTest < ActiveSupport::TestCase
  test "sell unit price and total sell cents calculate correctly" do
    account = Account.create!(name: "Hammertime")
    customer = account.customers.create!(name: "Acme")
    job = account.jobs.create!(customer: customer, title: "Job", status: "active")

    purchase = MaterialPurchase.create!(
      account: account,
      job: job,
      purchased_on: Date.current,
      supplier_name: "Supplier",
      description: "Wood",
      quantity: 3.5,
      unit_cost_cents: 1000,
      markup_percent: 10
    )

    assert_equal 1100, purchase.sell_unit_price_cents
    assert_equal 3850, purchase.total_sell_cents
  end
end
