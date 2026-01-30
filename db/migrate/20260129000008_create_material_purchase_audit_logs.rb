class CreateMaterialPurchaseAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :material_purchase_audit_logs do |t|
      t.references :account, null: false, foreign_key: true
      t.references :material_purchase, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.text :details

      t.timestamps
    end
  end
end
