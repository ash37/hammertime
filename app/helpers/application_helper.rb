module ApplicationHelper
  include Pagy::Frontend if defined?(Pagy::Frontend)
end
