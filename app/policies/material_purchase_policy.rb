class MaterialPurchasePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && same_account?
  end

  def create?
    return false unless user.present? && same_account?

    user.owner? || user.admin? || user.staff?
  end

  def update?
    manage?
  end

  def destroy?
    manage?
  end

  private

  def manage?
    user.present? && same_account? && (user.owner? || user.admin?)
  end
end
