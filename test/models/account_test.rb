require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "is valid with a name" do
    account = Account.new(name: "Hammertime")
    assert account.valid?
  end

  test "is invalid without a name" do
    account = Account.new
    assert_not account.valid?
  end
end
