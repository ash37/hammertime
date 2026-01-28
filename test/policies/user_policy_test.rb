require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "admin can manage users in account" do
    account = Account.create!(name: "Hammertime")
    admin = account.users.create!(email: "admin@example.com", name: "Admin", password: "password123", role: "admin")
    user = account.users.create!(email: "staff@example.com", name: "Staff", password: "password123", role: "staff")

    policy = UserPolicy.new(admin, user)
    assert policy.index?
    assert policy.update?
    assert policy.destroy?
  end

  test "staff cannot manage users" do
    account = Account.create!(name: "Hammertime")
    staff = account.users.create!(email: "staff@example.com", name: "Staff", password: "password123", role: "staff")
    other = account.users.create!(email: "other@example.com", name: "Other", password: "password123", role: "staff")

    policy = UserPolicy.new(staff, other)
    assert_not policy.index?
    assert_not policy.update?
  end

  test "scope limits users to account" do
    account = Account.create!(name: "Hammertime")
    other_account = Account.create!(name: "Other")
    admin = account.users.create!(email: "admin@example.com", name: "Admin", password: "password123", role: "admin")
    account_user = account.users.create!(email: "a@example.com", name: "A", password: "password123", role: "staff")
    other_user = other_account.users.create!(email: "b@example.com", name: "B", password: "password123", role: "staff")

    scope = UserPolicy::Scope.new(admin, User.all).resolve

    assert_includes scope, account_user
    assert_not_includes scope, other_user
  end
end
