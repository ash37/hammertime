# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
account = Account.find_or_create_by!(name: "Hammertime") do |record|
  record.default_hourly_rate_cents = 8500
  record.company_name = "Hammertime Pty Ltd"
  record.gst_registered = true
  record.abn = "12 345 678 901"
  record.company_licence_number = "QBCC 123456"
end

owner = account.users.find_or_create_by!(email: "owner@hammertime.test") do |user|
  user.password = "password123"
  user.role = "owner"
  user.hourly_rate_cents = 8500
  user.name = "Alex Turner"
  user.mobile = "+61 400 000 000"
  user.default_billing_rate_cents = 15000
  user.hourly_cost_cents = 9000
end

customer = account.customers.find_or_create_by!(name: "Acme Property Group") do |record|
  record.email = "accounts@acme.test"
  record.phone = "+61 7 5555 0000"
  record.billing_address = "123 Queen Street\\nBrisbane QLD 4000"
end

job = account.jobs.find_or_create_by!(customer: customer, title: "New tenant fit-out") do |record|
  record.description = "Kitchen and bathroom renovation"
  record.site_address = "88 Adelaide Street, Brisbane QLD"
  record.status = "active"
end

timesheet_one = account.timesheet_entries.find_or_create_by!(user: owner, job: job, work_date: Date.current - 2) do |record|
  record.minutes = 240
  record.hourly_rate_cents = 8500
  record.notes = "Initial demolition and site prep"
end

timesheet_two = account.timesheet_entries.find_or_create_by!(user: owner, job: job, work_date: Date.current - 1) do |record|
  record.minutes = 180
  record.hourly_rate_cents = 8500
  record.notes = "Plumbing rough-in"
end

material_one = account.material_purchases.find_or_create_by!(job: job, purchased_on: Date.current - 3, supplier_name: "Brisbane Timber") do |record|
  record.description = "Hardwood panels"
  record.quantity = 12.5
  record.unit_cost_cents = 3200
  record.markup_percent = 20
end

material_two = account.material_purchases.find_or_create_by!(job: job, purchased_on: Date.current - 2, supplier_name: "Spark Supplies") do |record|
  record.description = "Lighting fixtures"
  record.quantity = 6
  record.unit_cost_cents = 5400
  record.markup_percent = 15
end

invoice = account.invoices.find_or_create_by!(customer: customer, job: job, issued_on: Date.current, due_on: Date.current + 14) do |record|
  record.status = "draft"
end

account.invoice_line_items.find_or_create_by!(invoice: invoice, source: timesheet_one) do |record|
  record.item_type = "labour"
  record.description = "Labour #{timesheet_one.work_date}"
  record.quantity = timesheet_one.hours
  record.unit_price_cents = timesheet_one.hourly_rate_cents
end

account.invoice_line_items.find_or_create_by!(invoice: invoice, source: timesheet_two) do |record|
  record.item_type = "labour"
  record.description = "Labour #{timesheet_two.work_date}"
  record.quantity = timesheet_two.hours
  record.unit_price_cents = timesheet_two.hourly_rate_cents
end

account.invoice_line_items.find_or_create_by!(invoice: invoice, source: material_one) do |record|
  record.item_type = "material"
  record.description = material_one.description
  record.quantity = material_one.quantity
  record.unit_price_cents = material_one.sell_unit_price_cents
end

account.invoice_line_items.find_or_create_by!(invoice: invoice, source: material_two) do |record|
  record.item_type = "material"
  record.description = material_two.description
  record.quantity = material_two.quantity
  record.unit_price_cents = material_two.sell_unit_price_cents
end
