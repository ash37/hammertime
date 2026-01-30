class CreateRosterEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :roster_entries do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :start_time
      t.time :end_time

      t.timestamps
    end

    add_index :roster_entries, [ :user_id, :day_of_week ], unique: true
    add_index :roster_entries, [ :account_id, :day_of_week ]
  end
end
