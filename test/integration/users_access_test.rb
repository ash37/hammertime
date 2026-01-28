require "test_helper"

class UsersAccessTest < ActionDispatch::IntegrationTest
  setup do
    @account = Account.create!(name: "Hammertime")
    @owner = @account.users.create!(email: "owner@example.com", name: "Owner", password: "password123", role: "owner")
    @admin = @account.users.create!(email: "admin@example.com", name: "Admin", password: "password123", role: "admin")
    @staff = @account.users.create!(email: "staff@example.com", name: "Staff", password: "password123", role: "staff")
  end

  test "staff cannot access users index" do
    sign_in @staff
    get users_path

    assert_redirected_to authenticated_root_path
  end

  test "admin can access users index" do
    sign_in @admin
    get users_path

    assert_response :success
  end

  test "admin creates user with dollar rates" do
    sign_in @owner

    assert_difference -> { User.count }, 1 do
      post users_path, params: {
        user: {
          name: "New User",
          email: "new@example.com",
          mobile: "+61 400 111 222",
          role: "staff",
          default_billing_rate_dollars: "35.50",
          hourly_cost_dollars: "22.25",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    user = User.find_by(email: "new@example.com")
    assert_equal @account.id, user.account_id
    assert_equal 3550, user.default_billing_rate_cents
    assert_equal 2225, user.hourly_cost_cents
  end

  test "cross-account access is blocked" do
    other_account = Account.create!(name: "Other")
    other_user = other_account.users.create!(email: "other@example.com", name: "Other", password: "password123", role: "staff")

    sign_in @admin

    assert_raises ActiveRecord::RecordNotFound do
      get user_path(other_user)
    end
  end
end
