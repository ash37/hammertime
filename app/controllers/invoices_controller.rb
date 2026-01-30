class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice, only: %i[show print add_labour add_materials mark_sent mark_paid void edit update]

  def index
    authorize Invoice
    @invoices = policy_scope(Invoice).includes(:customer, :job).order(issued_on: :desc, created_at: :desc)
  end

  def new
    @invoice = Invoice.new(account: current_account, status: :draft, issued_on: Date.current, due_on: Date.current + 14)
    authorize @invoice
    load_invoice_form_collections
  end

  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.account = current_account
    @invoice.status = :draft
    @invoice.issued_on ||= Date.current
    @invoice.due_on ||= Date.current + 14
    authorize @invoice

    if @invoice.save
      redirect_to invoice_path(@invoice), notice: "Draft invoice created."
    else
      load_invoice_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @invoice
    ensure_draft!
    load_invoice_form_collections
  end

  def update
    authorize @invoice
    ensure_draft!

    if @invoice.update(invoice_params)
      redirect_to invoice_path(@invoice), notice: "Invoice updated."
    else
      load_invoice_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    authorize @invoice
    load_invoice_context
  end

  def print
    authorize @invoice
    load_invoice_context
    render layout: "print"
  end

  def add_labour
    authorize @invoice, :update?
    ensure_admin!

    timesheet_ids = Array(params[:timesheet_entry_ids]).reject(&:blank?)
    selected = policy_scope(TimesheetEntry)
               .where(job: @invoice.job, id: timesheet_ids, status: :unbilled)
               .left_joins(:invoice_line_item)
               .where(invoice_line_items: { id: nil })

    selected.find_each do |entry|
      InvoiceLineItem.create!(
        account: current_account,
        invoice: @invoice,
        source: entry,
        item_type: "labour",
        description: labour_description(entry),
        quantity: entry.hours,
        unit_price_cents: entry.hourly_rate_cents
      )
    end

    load_invoice_context

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Added #{selected.size} timesheets."
        render turbo_stream: invoice_stream_updates
      end
      format.html { redirect_to invoice_path(@invoice), notice: "Added #{selected.size} timesheets." }
    end
  end

  def add_materials
    authorize @invoice, :update?
    ensure_admin!

    material_ids = Array(params[:material_purchase_ids]).reject(&:blank?)
    selected = policy_scope(MaterialPurchase)
               .where(job: @invoice.job, id: material_ids)
               .left_joins(:invoice_line_item)
               .where(invoice_line_items: { id: nil })

    selected.find_each do |purchase|
      InvoiceLineItem.create!(
        account: current_account,
        invoice: @invoice,
        source: purchase,
        item_type: "material",
        description: material_description(purchase),
        quantity: purchase.quantity,
        unit_price_cents: purchase.sell_unit_price_cents
      )
    end

    load_invoice_context

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Added #{selected.size} materials."
        render turbo_stream: invoice_stream_updates
      end
      format.html { redirect_to invoice_path(@invoice), notice: "Added #{selected.size} materials." }
    end
  end

  def mark_sent
    update_status!(:sent)
  end

  def mark_paid
    update_status!(:paid)
  end

  def void
    update_status!(:void)
  end

  private

  def set_invoice
    @invoice = policy_scope(Invoice).find(params[:id])
  end

  def load_invoice_context
    @line_items = @invoice.invoice_line_items.order(created_at: :asc)

    if @invoice.job
      @unbilled_timesheets = policy_scope(TimesheetEntry)
                             .where(job: @invoice.job, status: :unbilled)
                             .left_joins(:invoice_line_item)
                             .where(invoice_line_items: { id: nil })
                             .includes(:user)

      @unbilled_materials = policy_scope(MaterialPurchase)
                            .where(job: @invoice.job)
                            .left_joins(:invoice_line_item)
                            .where(invoice_line_items: { id: nil })
    else
      @unbilled_timesheets = TimesheetEntry.none
      @unbilled_materials = MaterialPurchase.none
    end
  end

  def ensure_admin!
    raise Pundit::NotAuthorizedError unless current_user&.owner? || current_user&.admin?
  end

  def update_status!(status)
    authorize @invoice, :update?
    ensure_admin!

    @invoice.update!(status: status)
    load_invoice_context

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Invoice marked #{status}."
        render turbo_stream: invoice_stream_updates
      end
      format.html { redirect_to invoice_path(@invoice), notice: "Invoice marked #{status}." }
    end
  end

  def labour_description(entry)
    "Labour — #{entry.user.display_name}, #{entry.work_date}, #{entry.hours.round(2)}h @ #{money_rate(entry.hourly_rate_cents)}"
  end

  def material_description(purchase)
    "Materials — #{purchase.description.presence || 'Material'} (#{purchase.supplier_name})"
  end

  def money_rate(cents)
    ActionController::Base.helpers.number_to_currency(cents / 100.0)
  end

  def invoice_stream_updates
    [
      turbo_stream.replace("invoice_line_items", partial: "invoices/line_items_table", locals: { invoice: @invoice, line_items: @line_items }),
      turbo_stream.replace("invoice_totals", partial: "invoices/totals", locals: { invoice: @invoice }),
      turbo_stream.replace("invoice_labour_picker", partial: "invoices/labour_picker", locals: { invoice: @invoice, unbilled_timesheets: @unbilled_timesheets }),
      turbo_stream.replace("invoice_materials_picker", partial: "invoices/materials_picker", locals: { invoice: @invoice, unbilled_materials: @unbilled_materials }),
      turbo_stream.replace("invoice_header", partial: "invoices/header", locals: { invoice: @invoice }),
      turbo_stream.replace("flash", partial: "shared/flash")
    ]
  end

  def load_invoice_form_collections
    @customers = policy_scope(Customer).active.order(:name)
    @jobs = policy_scope(Job).order(:title)
  end

  def invoice_params
    params.require(:invoice).permit(:customer_id, :job_id, :issued_on, :due_on)
  end

  def ensure_draft!
    return if @invoice.draft?

    redirect_to invoice_path(@invoice), alert: "Only draft invoices can be edited."
  end
end
