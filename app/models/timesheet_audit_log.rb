class TimesheetAuditLog < ApplicationRecord
  include AccountOwned

  belongs_to :timesheet_entry
  belongs_to :user, optional: true

  validates :action, presence: true
end
