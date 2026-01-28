class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pundit::Authorization

  include Pagy::Backend if defined?(Pagy::Backend)

  before_action :set_current_context

  helper_method :current_account

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def current_account
    current_user&.account
  end

  def scope_current_account(relation)
    return relation.none unless current_account

    relation.where(account: current_account)
  end

  private

  def set_current_context
    Current.user = current_user
    Current.account = current_account
  end

  def user_not_authorized
    redirect_to authenticated_root_path, alert: "You are not authorized to perform that action."
  end
end
