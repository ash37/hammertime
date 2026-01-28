class MaterialPurchasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_material_purchase, only: %i[edit update]

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

  def new
    @material_purchase = MaterialPurchase.new(account: current_account)
    @material_purchase.job_id = params[:job_id] if params[:job_id].present?
    @material_purchase.purchased_on ||= Date.current
    authorize @material_purchase

    @unit_cost_dollars = (@material_purchase.unit_cost_cents.to_f / 100)

    load_form_collections
  end

  def create
    @material_purchase = MaterialPurchase.new(material_purchase_params)
    @material_purchase.account = current_account

    apply_unit_cost(@material_purchase)

    authorize @material_purchase

    if @material_purchase.save
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
    apply_unit_cost(@material_purchase)

    if @material_purchase.save
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
    params.require(:material_purchase).permit(:job_id, :purchased_on, :supplier_name, :description, :quantity, :markup_percent)
  end

  def apply_unit_cost(purchase)
    cost_value = params.dig(:material_purchase, :unit_cost_dollars)
    return if cost_value.blank?

    purchase.unit_cost_cents = (cost_value.to_f * 100).round
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
end
