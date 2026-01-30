class TimesheetEntry < ApplicationRecord
  include AccountOwned

  belongs_to :user
  belongs_to :job, optional: true
  has_one :invoice_line_item, as: :source, dependent: :nullify

  enum :status, { draft: 0, unbilled: 1 }, default: :unbilled

  validates :work_date, presence: true
  validates :job, presence: true, unless: :draft?
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

  def self.generate_drafts_for(date = Date.current, account: nil, job: nil)
    day_of_week = date.wday
    created = 0

    scope = User.includes(:roster_entries).where(deactivated_at: nil)
    scope = scope.where(account: account) if account

    scope.find_each do |user|
      roster_entry = user.roster_entries.find { |entry| entry.day_of_week == day_of_week }
      next unless roster_entry&.total_minutes.to_i.positive?
      next if where(user: user, work_date: date).exists?

      create!(
        account: user.account,
        user: user,
        job: job,
        work_date: date,
        minutes: roster_entry.total_minutes,
        hourly_rate_cents: user.default_billing_rate_cents,
        status: :draft
      )

      created += 1
    end

    created
  end
end
