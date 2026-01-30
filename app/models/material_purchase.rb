class MaterialPurchase < ApplicationRecord
  include AccountOwned

  belongs_to :job
  belongs_to :user, optional: true
  has_one :invoice_line_item, as: :source, dependent: :nullify
  has_many :audit_logs, class_name: "MaterialPurchaseAuditLog", dependent: :destroy

  validates :purchased_on, presence: true
  validates :supplier_name, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_cost_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :markup_percent, numericality: { greater_than_or_equal_to: 0 }

  def sell_unit_price_cents
    multiplier = 1 + (markup_percent.to_f / 100)
    (unit_cost_cents * multiplier).round
  end

  def total_sell_cents
    (sell_unit_price_cents * quantity.to_f).round
  end

  def billed?
    invoice_line_item.present?
  end
end
