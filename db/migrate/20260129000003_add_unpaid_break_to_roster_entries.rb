class AddUnpaidBreakToRosterEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :roster_entries, :unpaid_break, :boolean, null: false, default: false
  end
end
