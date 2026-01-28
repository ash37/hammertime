class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def same_account?
    return false unless user
    return true unless record.respond_to?(:account_id)

    record.account_id == user.account_id
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.none unless user
      return scope.all unless scope.respond_to?(:column_names)

      if scope.column_names.include?("account_id")
        scope.where(account_id: user.account_id)
      else
        scope.all
      end
    end
  end
end
