class Settings::CompanyDetailsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @account = current_account
    authorize @account, :update?
  end

  def update
    @account = current_account
    authorize @account, :update?

    if @account.update(account_params)
      redirect_to edit_settings_company_path, notice: "Company details updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:company_name, :gst_registered, :abn, :company_licence_number, :payroll_day)
  end
end
