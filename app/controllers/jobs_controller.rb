class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: %i[show add_timesheets_to_invoice add_materials_to_invoice]

  def index
    authorize Job
    @jobs = policy_scope(Job).includes(:customer).order(created_at: :desc)
  end

  def show
    authorize @job

    @timesheets = policy_scope(TimesheetEntry).where(job: @job).includes(:user).order(work_date: :desc)
    @unbilled_timesheets = @timesheets.left_joins(:invoice_line_item).where(invoice_line_items: { id: nil })
    @draft_invoices = policy_scope(Invoice).where(job: @job, status: :draft).order(created_at: :desc)

    @materials = policy_scope(MaterialPurchase).where(job: @job).order(purchased_on: :desc)
    @unbilled_materials = @materials.left_joins(:invoice_line_item).where(invoice_line_items: { id: nil })
  end

  def add_timesheets_to_invoice
    authorize @job, :update?
    raise Pundit::NotAuthorizedError unless current_user&.owner? || current_user&.admin?

    timesheet_ids = Array(params[:timesheet_entry_ids]).reject(&:blank?)
    selected = policy_scope(TimesheetEntry)
               .where(job: @job, id: timesheet_ids)
               .left_joins(:invoice_line_item)
               .where(invoice_line_items: { id: nil })

    invoice = find_or_create_invoice

    selected.find_each do |entry|
      InvoiceLineItem.create!(
        account: current_account,
        invoice: invoice,
        source: entry,
        item_type: "labour",
        description: "Labour — #{entry.user.display_name}, #{entry.work_date}, #{entry.hours.round(2)}h @ #{money_rate(entry.hourly_rate_cents)}",
        quantity: entry.hours,
        unit_price_cents: entry.hourly_rate_cents
      )
    end

    @timesheets = policy_scope(TimesheetEntry).where(job: @job).includes(:user).order(work_date: :desc)
    @unbilled_timesheets = @timesheets.left_joins(:invoice_line_item).where(invoice_line_items: { id: nil })
    @draft_invoices = policy_scope(Invoice).where(job: @job, status: :draft).order(created_at: :desc)

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Added #{selected.size} timesheets to invoice #{invoice.invoice_number}."
        render turbo_stream: [
          turbo_stream.replace("job_timesheets_panel", partial: "jobs/timesheets_panel", locals: panel_locals),
          turbo_stream.replace("flash", partial: "shared/flash")
        ]
      end
      format.html { redirect_to job_path(@job), notice: "Added #{selected.size} timesheets." }
    end
  end

  def add_materials_to_invoice
    authorize @job, :update?
    raise Pundit::NotAuthorizedError unless current_user&.owner? || current_user&.admin?

    material_ids = Array(params[:material_purchase_ids]).reject(&:blank?)
    selected = policy_scope(MaterialPurchase)
               .where(job: @job, id: material_ids)
               .left_joins(:invoice_line_item)
               .where(invoice_line_items: { id: nil })

    invoice = find_or_create_invoice

    selected.find_each do |purchase|
      InvoiceLineItem.create!(
        account: current_account,
        invoice: invoice,
        source: purchase,
        item_type: "material",
        description: "Materials — #{purchase.description.presence || 'Material'} (#{purchase.supplier_name})",
        quantity: purchase.quantity,
        unit_price_cents: purchase.sell_unit_price_cents
      )
    end

    @materials = policy_scope(MaterialPurchase).where(job: @job).order(purchased_on: :desc)
    @unbilled_materials = @materials.left_joins(:invoice_line_item).where(invoice_line_items: { id: nil })
    @draft_invoices = policy_scope(Invoice).where(job: @job, status: :draft).order(created_at: :desc)

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Added #{selected.size} materials to invoice #{invoice.invoice_number}."
        render turbo_stream: [
          turbo_stream.replace("job_materials_panel", partial: "jobs/materials_panel", locals: panel_materials_locals),
          turbo_stream.replace("flash", partial: "shared/flash")
        ]
      end
      format.html { redirect_to job_path(@job), notice: "Added #{selected.size} materials." }
    end
  end

  private

  def set_job
    @job = policy_scope(Job).find(params[:id])
  end

  def find_or_create_invoice
    invoice_id = params[:invoice_id]

    if invoice_id.present? && invoice_id != "new"
      invoice = policy_scope(Invoice).find(invoice_id)
      raise Pundit::NotAuthorizedError unless invoice.job_id == @job.id && invoice.draft?
      return invoice
    end

    Invoice.create!(
      account: current_account,
      customer: @job.customer,
      job: @job,
      status: "draft",
      issued_on: Date.current,
      due_on: Date.current + 14
    )
  end

  def panel_locals
    { job: @job, unbilled_timesheets: @unbilled_timesheets, draft_invoices: @draft_invoices }
  end

  def panel_materials_locals
    { job: @job, unbilled_materials: @unbilled_materials, draft_invoices: @draft_invoices }
  end

  def money_rate(cents)
    ActionController::Base.helpers.number_to_currency(cents / 100.0)
  end
end
