class AddHourlyRates < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :default_hourly_rate_cents, :integer, null: false, default: 0
    add_column :users, :hourly_rate_cents, :integer, null: false, default: 0
  end
end
