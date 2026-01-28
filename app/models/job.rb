class Job < ApplicationRecord
  include AccountOwned

  belongs_to :customer

  has_many :timesheet_entries, dependent: :destroy
  has_many :material_purchases, dependent: :destroy
  has_many :invoices, dependent: :nullify

  enum :status, { prospect: "prospect", active: "active", completed: "completed", archived: "archived" }, default: "prospect"

  validates :title, presence: true
  validates :status, presence: true
end
