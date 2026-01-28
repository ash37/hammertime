class AddCustomerArchivedAt < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :archived_at, :datetime
    add_index :customers, :archived_at
  end
end
