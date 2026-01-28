class AddUserManagementFields < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :mobile, :string
    add_column :users, :default_billing_rate_cents, :integer, null: false, default: 0
    add_column :users, :hourly_cost_cents, :integer, null: false, default: 0
    add_column :users, :deactivated_at, :datetime
    add_column :users, :invitation_sent_at, :datetime

    add_index :users, :deactivated_at
  end
end
