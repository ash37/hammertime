class MaterialPurchaseAuditLog < ApplicationRecord
  include AccountOwned

  belongs_to :material_purchase
  belongs_to :user, optional: true

  validates :action, presence: true
end
