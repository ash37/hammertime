require "test_helper"

class MaterialPurchasePolicyTest < ActiveSupport::TestCase
  test "staff can create but not update materials" do
    account = Account.create!(name: "Hammertime")
    staff = account.users.create!(email: "staff@example.com", name: "Staff", password: "password123", role: "staff")
    customer = account.customers.create!(name: "Acme")
    job = account.jobs.create!(customer: customer, title: "Job", status: "active")
    purchase = MaterialPurchase.new(account: account, job: job, purchased_on: Date.current, supplier_name: "Supplier")

    policy = MaterialPurchasePolicy.new(staff, purchase)
    assert policy.create?
    assert_not policy.update?
  end

  test "admin can manage materials" do
    account = Account.create!(name: "Hammertime")
    admin = account.users.create!(email: "admin@example.com", name: "Admin", password: "password123", role: "admin")
    customer = account.customers.create!(name: "Acme")
    job = account.jobs.create!(customer: customer, title: "Job", status: "active")
    purchase = MaterialPurchase.new(account: account, job: job, purchased_on: Date.current, supplier_name: "Supplier")

    policy = MaterialPurchasePolicy.new(admin, purchase)
    assert policy.update?
    assert policy.destroy?
  end
end
