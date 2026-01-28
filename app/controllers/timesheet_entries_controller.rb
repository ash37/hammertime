class TimesheetEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_timesheet_entry, only: %i[edit update]

  def index
    authorize TimesheetEntry

    @jobs = policy_scope(Job).order(:title)
    @users = current_user.owner? || current_user.admin? ? policy_scope(User).order(:email) : []

    scope = policy_scope(TimesheetEntry).includes(:job, :user)

    from_date = parse_date(params[:from])
    to_date = parse_date(params[:to])
    if from_date && to_date
      scope = scope.where(work_date: from_date..to_date)
    elsif from_date
      scope = scope.where("work_date >= ?", from_date)
    elsif to_date
      scope = scope.where("work_date <= ?", to_date)
    end

    if params[:job_id].present?
      scope = scope.where(job_id: params[:job_id])
    end

    if (current_user.owner? || current_user.admin?) && params[:user_id].present?
      scope = scope.where(user_id: params[:user_id])
    end

    case params[:billed]
    when "billed"
      scope = scope.joins(:invoice_line_item)
    when "unbilled"
      scope = scope.left_joins(:invoice_line_item).where(invoice_line_items: { id: nil })
    end

    @timesheet_entries = scope.order(work_date: :desc, created_at: :desc)
  end

  def new
    @timesheet_entry = TimesheetEntry.new(account: current_account, user: current_user)
    @timesheet_entry.job_id = params[:job_id] if params[:job_id].present?
    @timesheet_entry.work_date ||= Date.current
    authorize @timesheet_entry

    @timesheet_entry.hourly_rate_cents ||= current_user.hourly_rate_cents || current_account&.default_hourly_rate_cents || 0
    build_form_state(@timesheet_entry)

    load_form_collections
  end

  def create
    @timesheet_entry = TimesheetEntry.new(timesheet_entry_params)
    @timesheet_entry.account = current_account
    @timesheet_entry.user = current_user unless user_assignable?

    apply_rate(@timesheet_entry)
    apply_duration(@timesheet_entry)

    authorize @timesheet_entry

    if @timesheet_entry.save
      redirect_to timesheet_entries_path, notice: "Timesheet entry created."
    else
      build_form_state(@timesheet_entry)
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @timesheet_entry
    build_form_state(@timesheet_entry)
    load_form_collections
  end

  def update
    authorize @timesheet_entry
    @timesheet_entry.assign_attributes(timesheet_entry_params)
    apply_rate(@timesheet_entry)
    apply_duration(@timesheet_entry)

    if @timesheet_entry.save
      redirect_to timesheet_entries_path, notice: "Timesheet entry updated."
    else
      build_form_state(@timesheet_entry)
      load_form_collections
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_timesheet_entry
    @timesheet_entry = policy_scope(TimesheetEntry).find(params[:id])
  end

  def timesheet_entry_params
    form_params = timesheet_entry_form_params
    allowed = [ :job_id, :work_date, :notes ]
    allowed << :user_id if user_assignable?
    form_params.slice(*allowed)
  end

  def user_assignable?
    current_user&.owner? || current_user&.admin?
  end

  def apply_duration(entry)
    hours = duration_params[:duration_hours].to_i
    minutes = duration_params[:duration_minutes].to_i
    entry.minutes = (hours * 60) + minutes
  end

  def apply_rate(entry)
    rate_value = duration_params[:hourly_rate_dollars]
    return if rate_value.blank?

    entry.hourly_rate_cents = (rate_value.to_f * 100).round
  end

  def duration_params
    timesheet_entry_form_params.slice(:duration_hours, :duration_minutes, :hourly_rate_dollars)
  end

  def timesheet_entry_form_params
    @timesheet_entry_form_params ||= params.require(:timesheet_entry)
      .permit(:job_id, :user_id, :work_date, :notes, :duration_hours, :duration_minutes, :hourly_rate_dollars)
  end

  def load_form_collections
    @jobs = policy_scope(Job).order(:title)
    @users = user_assignable? ? policy_scope(User).order(:email) : []
  end

  def parse_date(value)
    return if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end

  def build_form_state(entry)
    @duration_hours = (entry.minutes / 60)
    @duration_minutes = (entry.minutes % 60)
    @hourly_rate_dollars = (entry.hourly_rate_cents.to_f / 100)
  end
end
