class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: %i[show edit update archive restore]

  def index
    authorize Customer

    @customers = policy_scope(Customer).order(:name)
    if params[:status] == "archived"
      @customers = @customers.where.not(archived_at: nil)
    else
      @customers = @customers.where(archived_at: nil)
    end
  end

  def show
    authorize @customer

    @jobs = policy_scope(Job).where(customer: @customer).order(created_at: :desc)
    @invoices = policy_scope(Invoice).where(customer: @customer).order(issued_on: :desc)
  end

  def new
    @customer = Customer.new(account: current_account)
    authorize @customer
  end

  def create
    @customer = Customer.new(customer_params)
    @customer.account = current_account
    authorize @customer

    if @customer.save
      if turbo_frame_request?
        @customers = policy_scope(Customer).active.order(:name)
        render turbo_stream: [
          turbo_stream.replace(
            "job_customer_select",
            partial: "jobs/customer_select",
            locals: { customers: @customers, selected_customer_id: @customer.id }
          ),
          turbo_stream.replace("modal", "")
        ]
      else
        redirect_to customer_path(@customer), notice: "Customer created."
      end
    else
      if turbo_frame_request?
        render :new, status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    authorize @customer
  end

  def update
    authorize @customer

    if @customer.update(customer_params)
      redirect_to customer_path(@customer), notice: "Customer updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def archive
    authorize @customer

    @customer.update!(archived_at: Time.current)
    redirect_to customers_path, notice: "Customer archived."
  end

  def restore
    authorize @customer

    @customer.update!(archived_at: nil)
    redirect_to customers_path(status: "archived"), notice: "Customer restored."
  end

  private

  def set_customer
    @customer = policy_scope(Customer).find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :email, :phone, :billing_address)
  end
end
