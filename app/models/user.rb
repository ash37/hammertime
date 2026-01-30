class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  belongs_to :account
  has_many :timesheet_entries, dependent: :destroy
  has_many :roster_entries, dependent: :destroy

  accepts_nested_attributes_for :roster_entries

  enum :role, { owner: "owner", admin: "admin", staff: "staff" }, default: "staff"

  validates :account, presence: true
  validates :name, presence: true
  validates :hourly_rate_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :default_billing_rate_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :hourly_cost_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def display_name
    name.presence || email
  end

  def first_name
    name.to_s.split(/\s+/).first
  end

  def build_roster_entries_for_week
    existing = roster_entries.index_by(&:day_of_week)
    (0..6).each do |day|
      roster_entries.build(day_of_week: day) unless existing.key?(day)
    end
    roster_entries.sort_by(&:day_of_week)
  end

  def active_for_authentication?
    super && deactivated_at.nil?
  end

  def inactive_message
    deactivated_at ? :inactive : super
  end
end
