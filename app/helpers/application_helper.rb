module ApplicationHelper
  include Pagy::Frontend if defined?(Pagy::Frontend)

  def time_picker_options(step_minutes = 30)
    options = []
    (0..23).each do |hour|
      (0...60).step(step_minutes) do |minute|
        value = format("%02d:%02d", hour, minute)
        hour12 = hour % 12
        hour12 = 12 if hour12.zero?
        suffix = hour < 12 ? "AM" : "PM"
        label = format("%d:%02d %s", hour12, minute, suffix)
        options << [label, value]
      end
    end
    options
  end
end
