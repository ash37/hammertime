module AccountOwned
  extend ActiveSupport::Concern

  included do
    belongs_to :account
    scope :for_account, ->(account) { where(account: account) }
  end
end
