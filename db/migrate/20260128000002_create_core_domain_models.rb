class CreateCoreDomainModels < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.text :billing_address
      t.timestamps
    end

    create_table :jobs do |t|
      t.references :account, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.text :site_address
      t.string :status, null: false, default: "prospect"
      t.timestamps
    end

    create_table :timesheet_entries do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true
      t.date :work_date, null: false
      t.integer :minutes, null: false, default: 0
      t.integer :hourly_rate_cents, null: false, default: 0
      t.text :notes
      t.timestamps
    end

    create_table :material_purchases do |t|
      t.references :account, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true
      t.date :purchased_on, null: false
      t.string :supplier_name, null: false
      t.text :description
      t.decimal :quantity, precision: 10, scale: 2, null: false, default: 0
      t.integer :unit_cost_cents, null: false, default: 0
      t.decimal :markup_percent, precision: 5, scale: 2, null: false, default: 0
      t.timestamps
    end

    create_table :invoices do |t|
      t.references :account, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :job, foreign_key: true
      t.string :status, null: false, default: "draft"
      t.date :issued_on, null: false
      t.date :due_on, null: false
      t.string :invoice_number, null: false
      t.timestamps
    end

    create_table :invoice_line_items do |t|
      t.references :account, null: false, foreign_key: true
      t.references :invoice, null: false, foreign_key: true
      t.string :item_type, null: false
      t.text :description, null: false
      t.decimal :quantity, precision: 10, scale: 2, null: false, default: 1
      t.integer :unit_price_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0
      t.string :source_type
      t.bigint :source_id
      t.timestamps
    end

    add_index :customers, [ :account_id, :email ]
    add_index :jobs, [ :account_id, :status ]
    add_index :timesheet_entries, [ :account_id, :work_date ]
    add_index :material_purchases, [ :account_id, :purchased_on ]
    add_index :invoices, [ :account_id, :invoice_number ], unique: true
    add_index :invoice_line_items, [ :source_type, :source_id ]
  end
end
