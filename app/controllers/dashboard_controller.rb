class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    timesheets_scope = policy_scope(TimesheetEntry).includes(:job, :user)
    materials_scope = policy_scope(MaterialPurchase).includes(:job)
    invoices_scope = policy_scope(Invoice)

    @today_minutes = timesheets_scope.where(work_date: Date.current).sum(:minutes)

    @unbilled_labour_cents = timesheets_scope
                             .left_joins(:invoice_line_item)
                             .where(invoice_line_items: { id: nil })
                             .sum(Arel.sql("timesheet_entries.hourly_rate_cents * timesheet_entries.minutes / 60.0"))
                             .to_i

    @unbilled_materials_cents = materials_scope
                                .left_joins(:invoice_line_item)
                                .where(invoice_line_items: { id: nil })
                                .sum(Arel.sql("material_purchases.unit_cost_cents * (1 + (material_purchases.markup_percent / 100.0)) * material_purchases.quantity"))
                                .to_i

    @draft_invoices_count = invoices_scope.where(status: :draft).count

    @recent_timesheets = timesheets_scope.order(work_date: :desc, created_at: :desc).limit(5)
    @recent_materials = materials_scope.order(purchased_on: :desc, created_at: :desc).limit(5)
  end
end
