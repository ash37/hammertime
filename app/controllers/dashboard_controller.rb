class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    timesheets_scope = policy_scope(TimesheetEntry).includes(:job, :user)
    materials_scope = policy_scope(MaterialPurchase).includes(:job)
    invoices_scope = policy_scope(Invoice)

    per_page = 5

    @timesheets_page = params.fetch(:timesheets_page, 1).to_i
    @timesheets_page = 1 if @timesheets_page < 1
    @timesheets_view = params[:timesheets_view] == "recent" ? "recent" : "action"
    action_timesheets_scope = timesheets_scope.left_joins(:invoice_line_item)
                                             .where(invoice_line_items: { id: nil })
    recent_timesheets_scope = timesheets_scope
    selected_timesheets_scope = @timesheets_view == "recent" ? recent_timesheets_scope : action_timesheets_scope
    timesheets_total = selected_timesheets_scope.count

    @materials_page = params.fetch(:materials_page, 1).to_i
    @materials_page = 1 if @materials_page < 1
    @materials_view = params[:materials_view] == "recent" ? "recent" : "action"
    action_materials_scope = materials_scope.left_joins(:invoice_line_item)
                                           .where(invoice_line_items: { id: nil })
    recent_materials_scope = materials_scope
    selected_materials_scope = @materials_view == "recent" ? recent_materials_scope : action_materials_scope
    materials_total = selected_materials_scope.count

    @today_minutes = timesheets_scope.where(work_date: Date.current).where.not(status: :draft).sum(:minutes)

    @unbilled_labour_cents = timesheets_scope
                             .where(status: :unbilled)
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

    @recent_timesheets = selected_timesheets_scope
                         .order(work_date: :desc, created_at: :desc)
                         .offset((@timesheets_page - 1) * per_page)
                         .limit(per_page)
    @timesheets_has_prev = @timesheets_page > 1
    @timesheets_has_next = timesheets_total > (@timesheets_page * per_page)

    @recent_materials = selected_materials_scope
                        .order(purchased_on: :desc, created_at: :desc)
                        .offset((@materials_page - 1) * per_page)
                        .limit(per_page)
    @materials_has_prev = @materials_page > 1
    @materials_has_next = materials_total > (@materials_page * per_page)
  end
end
