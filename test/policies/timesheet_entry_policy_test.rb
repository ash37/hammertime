require "test_helper"

class TimesheetEntryPolicyTest < ActiveSupport::TestCase
  test "staff can manage only their own timesheets" do
    account = Account.create!(name: "Hammertime")
    staff = account.users.create!(email: "staff@example.com", name: "Staff", password: "password123", role: "staff")
    other = account.users.create!(email: "other@example.com", name: "Other", password: "password123", role: "staff")
    customer = account.customers.create!(name: "Acme")
    job = account.jobs.create!(customer: customer, title: "Job", status: "active")

    own_entry = TimesheetEntry.new(account: account, user: staff, job: job)
    other_entry = TimesheetEntry.new(account: account, user: other, job: job)

    assert TimesheetEntryPolicy.new(staff, own_entry).update?
    assert_not TimesheetEntryPolicy.new(staff, other_entry).update?
  end

  test "admin can manage all timesheets in account" do
    account = Account.create!(name: "Hammertime")
    admin = account.users.create!(email: "admin@example.com", name: "Admin", password: "password123", role: "admin")
    staff = account.users.create!(email: "staff@example.com", name: "Staff", password: "password123", role: "staff")
    customer = account.customers.create!(name: "Acme")
    job = account.jobs.create!(customer: customer, title: "Job", status: "active")

    entry = TimesheetEntry.new(account: account, user: staff, job: job)

    assert TimesheetEntryPolicy.new(admin, entry).update?
    assert TimesheetEntryPolicy.new(admin, entry).destroy?
  end
end
