class UpdateUserRoles < ActiveRecord::Migration[8.0]
  def up
    change_column_default :users, :role, from: "member", to: "staff"
    execute "UPDATE users SET role = 'staff' WHERE role = 'member'"
  end

  def down
    execute "UPDATE users SET role = 'member' WHERE role = 'staff'"
    change_column_default :users, :role, from: "staff", to: "member"
  end
end
