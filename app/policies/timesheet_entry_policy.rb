class TimesheetEntryPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    same_account? && (manage_all? || owns_record?)
  end

  def create?
    same_account? && (manage_all? || owns_record?)
  end

  def update?
    same_account? && (manage_all? || owns_record?)
  end

  def destroy?
    same_account? && (manage_all? || owns_record?)
  end

  def approve?
    same_account? && manage_all?
  end

  def draft_payroll?
    manage_all?
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

  def manage_all?
    user.owner? || user.admin?
  end

  def owns_record?
    record.respond_to?(:user_id) && record.user_id == user.id
  end
end
