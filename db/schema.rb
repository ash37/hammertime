# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_29_000009) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_hourly_rate_cents", default: 0, null: false
    t.string "company_name"
    t.boolean "gst_registered", default: false, null: false
    t.string "abn"
    t.string "company_licence_number"
    t.integer "payroll_day", default: 1, null: false
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.string "email"
    t.string "phone"
    t.text "billing_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["account_id", "email"], name: "index_customers_on_account_id_and_email"
    t.index ["account_id"], name: "index_customers_on_account_id"
    t.index ["archived_at"], name: "index_customers_on_archived_at"
  end

  create_table "invoice_line_items", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "invoice_id", null: false
    t.string "item_type", null: false
    t.text "description", null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0", null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.string "source_type"
    t.bigint "source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_invoice_line_items_on_account_id"
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
    t.index ["source_type", "source_id"], name: "index_invoice_line_items_on_source_type_and_source_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "customer_id", null: false
    t.bigint "job_id"
    t.string "status", default: "draft", null: false
    t.date "issued_on", null: false
    t.date "due_on", null: false
    t.string "invoice_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "invoice_number"], name: "index_invoices_on_account_id_and_invoice_number", unique: true
    t.index ["account_id"], name: "index_invoices_on_account_id"
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
    t.index ["job_id"], name: "index_invoices_on_job_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "customer_id", null: false
    t.string "title", null: false
    t.text "description"
    t.text "site_address"
    t.string "status", default: "prospect", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "default_material_markup_percent", precision: 5, scale: 2
    t.index ["account_id", "status"], name: "index_jobs_on_account_id_and_status"
    t.index ["account_id"], name: "index_jobs_on_account_id"
    t.index ["customer_id"], name: "index_jobs_on_customer_id"
  end

  create_table "material_purchase_audit_logs", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "material_purchase_id", null: false
    t.bigint "user_id"
    t.string "action", null: false
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_material_purchase_audit_logs_on_account_id"
    t.index ["material_purchase_id"], name: "index_material_purchase_audit_logs_on_material_purchase_id"
    t.index ["user_id"], name: "index_material_purchase_audit_logs_on_user_id"
  end

  create_table "material_purchases", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "job_id", null: false
    t.date "purchased_on", null: false
    t.string "supplier_name", null: false
    t.text "description"
    t.decimal "quantity", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "unit_cost_cents", default: 0, null: false
    t.decimal "markup_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["account_id", "purchased_on"], name: "index_material_purchases_on_account_id_and_purchased_on"
    t.index ["account_id"], name: "index_material_purchases_on_account_id"
    t.index ["job_id"], name: "index_material_purchases_on_job_id"
    t.index ["user_id"], name: "index_material_purchases_on_user_id"
  end

  create_table "roster_entries", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
    t.integer "day_of_week", null: false
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "unpaid_break", default: false, null: false
    t.index ["account_id", "day_of_week"], name: "index_roster_entries_on_account_id_and_day_of_week"
    t.index ["account_id"], name: "index_roster_entries_on_account_id"
    t.index ["user_id", "day_of_week"], name: "index_roster_entries_on_user_id_and_day_of_week", unique: true
    t.index ["user_id"], name: "index_roster_entries_on_user_id"
  end

  create_table "timesheet_audit_logs", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "timesheet_entry_id", null: false
    t.bigint "user_id"
    t.string "action", null: false
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_timesheet_audit_logs_on_account_id"
    t.index ["timesheet_entry_id"], name: "index_timesheet_audit_logs_on_timesheet_entry_id"
    t.index ["user_id"], name: "index_timesheet_audit_logs_on_user_id"
  end

  create_table "timesheet_entries", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "user_id", null: false
    t.bigint "job_id"
    t.date "work_date", null: false
    t.integer "minutes", default: 0, null: false
    t.integer "hourly_rate_cents", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 1, null: false
    t.index ["account_id", "work_date"], name: "index_timesheet_entries_on_account_id_and_work_date"
    t.index ["account_id"], name: "index_timesheet_entries_on_account_id"
    t.index ["job_id"], name: "index_timesheet_entries_on_job_id"
    t.index ["status"], name: "index_timesheet_entries_on_status"
    t.index ["user_id"], name: "index_timesheet_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "role", default: "staff", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hourly_rate_cents", default: 0, null: false
    t.string "name"
    t.string "mobile"
    t.integer "default_billing_rate_cents", default: 0, null: false
    t.integer "hourly_cost_cents", default: 0, null: false
    t.datetime "deactivated_at"
    t.datetime "invitation_sent_at"
    t.index ["account_id", "name"], name: "index_users_on_account_id_and_name"
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["deactivated_at"], name: "index_users_on_deactivated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "customers", "accounts"
  add_foreign_key "invoice_line_items", "accounts"
  add_foreign_key "invoice_line_items", "invoices"
  add_foreign_key "invoices", "accounts"
  add_foreign_key "invoices", "customers"
  add_foreign_key "invoices", "jobs"
  add_foreign_key "jobs", "accounts"
  add_foreign_key "jobs", "customers"
  add_foreign_key "material_purchase_audit_logs", "accounts"
  add_foreign_key "material_purchase_audit_logs", "material_purchases"
  add_foreign_key "material_purchase_audit_logs", "users"
  add_foreign_key "material_purchases", "accounts"
  add_foreign_key "material_purchases", "jobs"
  add_foreign_key "material_purchases", "users"
  add_foreign_key "roster_entries", "accounts"
  add_foreign_key "roster_entries", "users"
  add_foreign_key "timesheet_audit_logs", "accounts"
  add_foreign_key "timesheet_audit_logs", "timesheet_entries"
  add_foreign_key "timesheet_audit_logs", "users"
  add_foreign_key "timesheet_entries", "accounts"
  add_foreign_key "timesheet_entries", "jobs"
  add_foreign_key "timesheet_entries", "users"
  add_foreign_key "users", "accounts"
end
