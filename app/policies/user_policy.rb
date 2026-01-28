class UserPolicy < ApplicationPolicy
  def index?
    manage?
  end

  def show?
    manage?
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

  class Scope < Scope
    def resolve
      return scope.none unless user

      scope.where(account_id: user.account_id)
    end
  end

  private

  def manage?
    user.present? && same_account? && (user.owner? || user.admin?)
  end
end
