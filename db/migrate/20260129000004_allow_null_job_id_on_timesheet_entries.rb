class AllowNullJobIdOnTimesheetEntries < ActiveRecord::Migration[8.0]
  def change
    change_column_null :timesheet_entries, :job_id, true
  end
end
