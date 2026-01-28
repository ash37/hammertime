class TimesheetEntry < ApplicationRecord
  include AccountOwned

  belongs_to :user
  belongs_to :job
  has_one :invoice_line_item, as: :source, dependent: :nullify

  validates :work_date, presence: true
  validates :minutes, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :hourly_rate_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def hours
    minutes.to_f / 60
  end

  def total_cents
    ((minutes.to_f * hourly_rate_cents) / 60).round
  end

  def billed?
    invoice_line_item.present?
  end
end
