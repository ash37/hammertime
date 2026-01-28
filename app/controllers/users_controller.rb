class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update destroy invite deactivate]

  def index
    authorize User
    scope = policy_scope(User)
    @users = scope.order(:name, :email)
  end

  def show
    authorize @user
  end

  def new
    @user = User.new(account: current_account)
    authorize @user

    prepare_currency_fields
  end

  def create
    @user = User.new(user_params)
    @user.account = current_account
    assign_currency_fields(@user)

    ensure_password(@user)

    authorize @user

    if @user.save
      send_invite_if_requested(@user)
      redirect_to user_path(@user), notice: "User created."
    else
      prepare_currency_fields
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
    prepare_currency_fields
  end

  def update
    authorize @user

    attrs = user_params
    if attrs[:password].blank?
      attrs.delete(:password)
      attrs.delete(:password_confirmation)
    end

    @user.assign_attributes(attrs)
    assign_currency_fields(@user)

    if @user.save
      send_invite_if_requested(@user)
      redirect_to user_path(@user), notice: "User updated."
    else
      prepare_currency_fields
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    return redirect_to users_path, alert: "You cannot deactivate yourself." if @user == current_user

    @user.update!(deactivated_at: Time.current)
    redirect_to users_path, notice: "User deactivated."
  end

  def deactivate
    authorize @user
    return redirect_to users_path, alert: "You cannot deactivate yourself." if @user == current_user

    @user.update!(deactivated_at: Time.current)
    redirect_to users_path, notice: "User deactivated."
  end

  def invite
    authorize @user
    send_invite(@user)
    redirect_to user_path(@user), notice: "Invitation sent."
  end

  private

  def set_user
    @user = policy_scope(User).find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :mobile, :role, :password, :password_confirmation)
  end

  def assign_currency_fields(user)
    billing_value = params.dig(:user, :default_billing_rate_dollars)
    cost_value = params.dig(:user, :hourly_cost_dollars)

    user.default_billing_rate_cents = (billing_value.to_f * 100).round if billing_value.present?
    user.hourly_cost_cents = (cost_value.to_f * 100).round if cost_value.present?
  end

  def prepare_currency_fields
    @default_billing_rate_dollars = (@user.default_billing_rate_cents.to_f / 100)
    @hourly_cost_dollars = (@user.hourly_cost_cents.to_f / 100)
  end

  def ensure_password(user)
    return if user.password.present?

    generated = SecureRandom.base58(12)
    user.password = generated
    user.password_confirmation = generated
  end

  def send_invite_if_requested(user)
    return unless params.dig(:user, :send_invite) == "1"

    send_invite(user)
  end

  def send_invite(user)
    user.send_reset_password_instructions
    user.update!(invitation_sent_at: Time.current)
  end
end
