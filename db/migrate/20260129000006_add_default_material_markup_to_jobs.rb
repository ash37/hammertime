class AddDefaultMaterialMarkupToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :default_material_markup_percent, :decimal, precision: 5, scale: 2
  end
end
