class AddPayrollDayToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :payroll_day, :integer, null: false, default: 1
  end
end
