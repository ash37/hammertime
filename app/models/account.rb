class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :jobs, dependent: :destroy
  has_many :timesheet_entries, dependent: :destroy
  has_many :roster_entries, dependent: :destroy
  has_many :material_purchases, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :invoice_line_items, dependent: :destroy

  before_validation :sync_company_name

  validates :name, presence: true
  validates :company_name, presence: true
  validates :gst_registered, inclusion: { in: [ true, false ] }
  validates :default_hourly_rate_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :payroll_day, inclusion: { in: 0..6 }

  def payroll_week_range(reference_date = Date.current)
    target_wday = payroll_day.to_i
    diff = (reference_date.wday - target_wday) % 7
    payroll_date = reference_date - diff
    end_date = payroll_date - 1
    start_date = end_date - 6
    start_date..end_date
  end

  private

  def sync_company_name
    self.company_name = name if company_name.blank?
  end
end
