class JobPolicy < ApplicationPolicy
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

  private

  def manage?
    user.present? && same_account? && (user.owner? || user.admin?)
  end
end
