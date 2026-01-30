class MaterialPurchasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_material_purchase, only: %i[show edit update]

  def index
    authorize MaterialPurchase

    @jobs = policy_scope(Job).order(:title)

    scope = policy_scope(MaterialPurchase).includes(:job)

    if params[:job_id].present?
      scope = scope.where(job_id: params[:job_id])
    end

    if params[:supplier].present?
      scope = scope.where("supplier_name ILIKE ?", "%#{params[:supplier]}%")
    end

    from_date = parse_date(params[:from])
    to_date = parse_date(params[:to])
    if from_date && to_date
      scope = scope.where(purchased_on: from_date..to_date)
    elsif from_date
      scope = scope.where("purchased_on >= ?", from_date)
    elsif to_date
      scope = scope.where("purchased_on <= ?", to_date)
    end

    case params[:billed]
    when "billed"
      scope = scope.joins(:invoice_line_item)
    when "unbilled"
      scope = scope.left_joins(:invoice_line_item).where(invoice_line_items: { id: nil })
    end

    @material_purchases = scope.order(purchased_on: :desc, created_at: :desc)
  end

  def show
    authorize @material_purchase
    @audit_logs = @material_purchase.audit_logs.includes(:user).order(created_at: :desc)
  end

  def new
    @material_purchase = MaterialPurchase.new(account: current_account)
    @material_purchase.job_id = params[:job_id] if params[:job_id].present?
    @material_purchase.purchased_on ||= Date.current
    if current_user&.staff?
      @material_purchase.quantity = 1 if @material_purchase.quantity.to_f <= 0
    end
    authorize @material_purchase

    @unit_cost_dollars = (@material_purchase.unit_cost_cents.to_f / 100)

    load_form_collections
  end

  def create
    @material_purchase = MaterialPurchase.new(material_purchase_params)
    @material_purchase.account = current_account
    @material_purchase.user = current_user
    apply_staff_defaults(@material_purchase)

    apply_unit_cost(@material_purchase)

    authorize @material_purchase

    if @material_purchase.save
      log_audit(@material_purchase, "created", "Material purchase created.")
      redirect_to material_purchases_path, notice: "Material purchase created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @material_purchase
    @unit_cost_dollars = (@material_purchase.unit_cost_cents.to_f / 100)
    load_form_collections
  end

  def update
    authorize @material_purchase
    @material_purchase.assign_attributes(material_purchase_params)
    @material_purchase.user ||= current_user
    apply_staff_defaults(@material_purchase)
    apply_unit_cost(@material_purchase)

    if @material_purchase.save
      log_audit(@material_purchase, "updated", update_details(@material_purchase))
      redirect_to material_purchases_path, notice: "Material purchase updated."
    else
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_material_purchase
    @material_purchase = policy_scope(MaterialPurchase).find(params[:id])
  end

  def material_purchase_params
    allowed = [ :job_id, :supplier_name, :description ]
    if current_user&.owner? || current_user&.admin?
      allowed += [ :purchased_on, :quantity, :markup_percent ]
    end
    params.require(:material_purchase).permit(*allowed)
  end

  def apply_unit_cost(purchase)
    cost_value = params.dig(:material_purchase, :unit_cost_dollars)
    return if cost_value.blank?

    purchase.unit_cost_cents = (cost_value.to_f * 100).round
  end

  def apply_staff_defaults(purchase)
    return unless current_user&.staff?

    purchase.purchased_on ||= Date.current
    purchase.quantity = 1 if purchase.quantity.to_f <= 0
    if purchase.markup_percent.blank? || purchase.will_save_change_to_job_id?
      purchase.markup_percent = purchase.job&.default_material_markup_percent.to_f
    end
  end

  def load_form_collections
    @jobs = policy_scope(Job).order(:title)
  end

  def parse_date(value)
    return if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end

  def log_audit(purchase, action, details = nil)
    MaterialPurchaseAuditLog.create!(
      account: current_account,
      material_purchase: purchase,
      user: current_user,
      action: action,
      details: details
    )
  end

  def update_details(purchase)
    changes = purchase.saved_changes.except("updated_at")
    return "Material purchase updated." if changes.empty?

    labels = {
      "job_id" => "Job",
      "purchased_on" => "Purchased on",
      "supplier_name" => "Supplier",
      "description" => "Description",
      "quantity" => "Quantity",
      "unit_cost_cents" => "Unit cost",
      "markup_percent" => "Markup"
    }
    fields = changes.keys.map { |key| labels[key] || key.humanize }.join(", ")
    "Updated fields: #{fields}."
  end
end
