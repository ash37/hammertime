class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  belongs_to :account
  has_many :timesheet_entries, dependent: :destroy

  enum :role, { owner: "owner", admin: "admin", staff: "staff" }, default: "staff"

  validates :account, presence: true
  validates :name, presence: true
  validates :hourly_rate_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :default_billing_rate_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :hourly_cost_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  def display_name
    name.presence || email
  end

  def active_for_authentication?
    super && deactivated_at.nil?
  end

  def inactive_message
    deactivated_at ? :inactive : super
  end
end
