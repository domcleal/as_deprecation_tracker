# frozen_string_literal: true
require 'active_support/subscriber'

module ASDeprecationTracker
  # Receives deprecation.rails events via ActiveSupport::Notifications
  class Receiver < ::ActiveSupport::Subscriber
    def deprecation(event)
    end
  end
end
