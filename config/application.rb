require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require_relative "../lib/auto_jwt"

Bundler.require(*Rails.groups)

module Tarnishedcore1
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true
    config.middleware.use AutoJwt
  end
end
