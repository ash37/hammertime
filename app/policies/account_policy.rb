class AccountPolicy < ApplicationPolicy
  def show?
    manage?
  end

  def update?
    manage?
  end

  def edit?
    update?
  end

  private

  def manage?
    user.present? && record.is_a?(Account) && record.id == user.account_id && (user.owner? || user.admin?)
  end
end
