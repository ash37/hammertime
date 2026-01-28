class AddUserName < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_index :users, [ :account_id, :name ]
  end
end
