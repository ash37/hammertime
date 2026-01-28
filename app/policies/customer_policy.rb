class CustomerPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && same_account?
  end

  def create?
    manage?
  end

  def update?
    manage?
  end

  def destroy?
    manage?
  end

  def archive?
    manage?
  end

  def restore?
    manage?
  end

  private

  def manage?
    user.present? && same_account? && (user.owner? || user.admin?)
  end
end
