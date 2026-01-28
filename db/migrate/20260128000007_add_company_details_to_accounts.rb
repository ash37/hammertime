class AddCompanyDetailsToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :company_name, :string
    add_column :accounts, :gst_registered, :boolean, null: false, default: false
    add_column :accounts, :abn, :string
    add_column :accounts, :company_licence_number, :string
  end
end
