class CreateTimesheetAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :timesheet_audit_logs do |t|
      t.references :account, null: false, foreign_key: true
      t.references :timesheet_entry, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.text :details

      t.timestamps
    end
  end
end
