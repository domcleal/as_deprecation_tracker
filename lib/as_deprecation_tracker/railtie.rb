# frozen_string_literal: true
module ASDeprecationTracker
  # Railtie to register for deprecation notifications
  class Railtie < ::Rails::Railtie
    initializer 'as_deprecation_tracker.deprecation_notifications' do
    end
  end
end
