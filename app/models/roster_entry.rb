class RosterEntry < ApplicationRecord
  include AccountOwned

  belongs_to :user

  validates :day_of_week, inclusion: { in: 0..6 }
  validate :times_present_together
  validate :end_after_start

  before_validation :assign_account

  def hours
    (total_minutes / 60.0).round(2)
  end

  def total_minutes
    return 0 unless start_time && end_time

    start_minutes = time_minutes(:start_time)
    end_minutes = time_minutes(:end_time)
    return 0 unless start_minutes && end_minutes

    diff = end_minutes - start_minutes
    diff -= 30 if unpaid_break? && diff.positive?
    diff.positive? ? diff : 0
  end

  def day_name
    Date::DAYNAMES[day_of_week]
  end

  private

  def assign_account
    self.account ||= user&.account
  end

  def times_present_together
    return if start_time.blank? && end_time.blank?
    return if start_time.present? && end_time.present?

    errors.add(:base, "Start and finish times must both be set.")
  end

  def end_after_start
    return unless start_time && end_time

    start_minutes = time_minutes(:start_time)
    end_minutes = time_minutes(:end_time)
    return if start_minutes.nil? || end_minutes.nil?

    errors.add(:end_time, "must be after start time.") if end_minutes <= start_minutes
  end

  def time_minutes(attribute_name)
    raw = attribute_before_type_cast(attribute_name)
    value = raw.presence || self[attribute_name]
    return if value.blank?

    if value.is_a?(String)
      parts = value.split(":")
      hours = parts[0].to_i
      minutes = parts[1].to_i
      (hours * 60) + minutes
    elsif value.respond_to?(:hour)
      (value.hour * 60) + value.min
    end
  end
end
