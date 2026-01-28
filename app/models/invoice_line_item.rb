class InvoiceLineItem < ApplicationRecord
  include AccountOwned

  belongs_to :invoice
  belongs_to :source, polymorphic: true, optional: true

  enum :item_type, { labour: "labour", material: "material", adjustment: "adjustment" }

  validates :item_type, presence: true
  validates :description, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :total_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  before_validation :compute_total_cents

  private

  def compute_total_cents
    return if quantity.blank? || unit_price_cents.blank?

    self.total_cents = (quantity.to_f * unit_price_cents).round
  end
end
