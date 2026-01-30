class AddUserToMaterialPurchases < ActiveRecord::Migration[8.0]
  def change
    add_reference :material_purchases, :user, foreign_key: true
  end
end
