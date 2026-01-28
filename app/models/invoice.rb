class Invoice < ApplicationRecord
  include AccountOwned

  belongs_to :customer
  belongs_to :job, optional: true

  has_many :invoice_line_items, dependent: :destroy

  enum :status, { draft: "draft", sent: "sent", paid: "paid", void: "void" }, default: "draft"

  validates :issued_on, presence: true
  validates :due_on, presence: true
  validates :invoice_number, presence: true, uniqueness: { scope: :account_id }, format: { with: /\A\d+\z/ }

  before_validation :assign_invoice_number, on: :create

  def subtotal_cents
    invoice_line_items.sum(:total_cents)
  end

  def total_cents
    subtotal_cents
  end

  private

  def assign_invoice_number
    return if invoice_number.present? || account.blank?

    last_number = account.invoices
                         .where.not(invoice_number: nil)
                         .order(Arel.sql("invoice_number::bigint DESC"))
                         .limit(1)
                         .pluck(Arel.sql("invoice_number::bigint"))
                         .first

    next_number = last_number.to_i + 1
    self.invoice_number = next_number.to_s.rjust(6, "0")
  end
end
