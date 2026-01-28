class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.for_current_account
    return all unless Current.account

    where(account: Current.account)
  end
end
