require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "is valid with account and credentials" do
    account = Account.create!(name: "Hammertime")
    user = User.new(
      account: account,
      email: "owner@example.com",
      name: "Owner",
      password: "password123",
      password_confirmation: "password123"
    )

    assert user.valid?
  end

  test "is invalid without account" do
    user = User.new(email: "owner@example.com", password: "password123", name: "Owner")
    assert_not user.valid?
  end

  test "requires a name" do
    account = Account.create!(name: "Hammertime")
    user = User.new(account: account, email: "owner@example.com", password: "password123")
    assert_not user.valid?
  end

  test "requires non-negative billing and cost rates" do
    account = Account.create!(name: "Hammertime")
    user = User.new(
      account: account,
      email: "owner@example.com",
      name: "Owner",
      password: "password123",
      default_billing_rate_cents: -1,
      hourly_cost_cents: -1
    )

    assert_not user.valid?
  end

  test "display_name falls back to email" do
    account = Account.create!(name: "Hammertime")
    user = User.new(account: account, email: "owner@example.com", name: "")

    assert_equal "owner@example.com", user.display_name
  end

  test "deactivated users are not active for authentication" do
    account = Account.create!(name: "Hammertime")
    user = User.new(
      account: account,
      email: "owner@example.com",
      name: "Owner",
      password: "password123",
      deactivated_at: Time.current
    )

    assert_not user.active_for_authentication?
  end
end
