class MaterialPurchasePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    same_account? && (manage? || owns_record?)
  end

  def create?
    return false unless user.present? && same_account?

    user.owner? || user.admin? || user.staff?
  end

  def update?
    same_account? && (manage? || owns_record?)
  end

  def destroy?
    manage?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      base = super
      return base if user.owner? || user.admin?

      base.where(user_id: user.id)
    end
  end

  private

  def manage?
    user.present? && same_account? && (user.owner? || user.admin?)
  end

  def owns_record?
    record.respond_to?(:user_id) && record.user_id == user.id
  end
end
