# frozen_string_literal: true

require 'as_deprecation_tracker/receiver'

module ASDeprecationTracker
  # Railtie to register for deprecation notifications
  class Railtie < ::Rails::Railtie
    initializer 'as_deprecation_tracker.deprecation_notifications', after: :load_environment_config, if: -> { ASDeprecationTracker.active? } do
      Receiver.attach_to :rails, ASDeprecationTracker.receiver
      ActiveSupport::Deprecation.behavior = :notify if ASDeprecationTracker.config.register_behavior?

      whitelist = ASDeprecationTracker.config.whitelist_file
      ([Rails.root] + engine_roots).each do |root|
        engine_whitelist = File.join(root, whitelist)
        ASDeprecationTracker.whitelist.load_file(engine_whitelist) if File.exist?(engine_whitelist)
      end
    end

    private

    def engine_roots
      ::Rails::Engine.descendants.map { |engine| engine.root rescue nil }.compact.uniq # rubocop:disable Style/RescueModifier
    end
  end
end
