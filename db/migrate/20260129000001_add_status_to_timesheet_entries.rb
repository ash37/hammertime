class AddStatusToTimesheetEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :timesheet_entries, :status, :integer, null: false, default: 1
    add_index :timesheet_entries, :status
  end
end
