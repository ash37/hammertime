class Customer < ApplicationRecord
  include AccountOwned

  has_many :jobs, dependent: :destroy
  has_many :invoices, dependent: :nullify

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  def archived?
    archived_at.present?
  end
end
