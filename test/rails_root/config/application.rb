require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module AdminDataDemo
  class Application < Rails::Application
    config.time_zone = 'Central Time (US & Canada)'
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
  end
end
