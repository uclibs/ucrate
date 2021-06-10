# frozen_string_literal: true
require 'aws-xray-sdk'

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ScholarUc
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.exceptions_app = routes
    config.eager_load_paths << Rails.root.join('lib')
    # REMOVE_ME: Temporarily remove strong params
    # config.action_controller.permit_all_parameters = true
    config.time_zone = "Eastern Time (US & Canada)"
    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    # Logging Configuration
    # Prepend all log lines with the following tags.
    config.log_tags = [:request_id, proc { XRay.recorder.current_segment.trace_id || "No-XRay-Trace-ID" }, :user_agent, :subdomain, :remote_ip, ->(request) { request.headers["X-Forwarded-For"] || "No-X-Forwarded-For-Header" }]
    config.log_level = :debug
  end
end
