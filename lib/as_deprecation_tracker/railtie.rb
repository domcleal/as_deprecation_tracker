# frozen_string_literal: true
require 'as_deprecation_tracker/receiver'

module ASDeprecationTracker
  # Railtie to register for deprecation notifications
  class Railtie < ::Rails::Railtie
    initializer 'as_deprecation_tracker.deprecation_notifications', after: :load_environment_config, if: -> { ASDeprecationTracker.active? } do
      Receiver.attach_to :rails
      ActiveSupport::Deprecation.behavior = :notify if ASDeprecationTracker.config.register_behavior?

      whitelist = File.join(Rails.root, 'config', 'as_deprecation_whitelist.yaml')
      ASDeprecationTracker.whitelist.load_file(whitelist) if File.exist?(whitelist)
    end
  end
end
