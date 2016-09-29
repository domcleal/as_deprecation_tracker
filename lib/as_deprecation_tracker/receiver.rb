# frozen_string_literal: true
require 'active_support/subscriber'

module ASDeprecationTracker
  # Receives deprecation.rails events via ActiveSupport::Notifications
  class Receiver < ::ActiveSupport::Subscriber
    def deprecation(event)
      return if ASDeprecationTracker.whitelist.matches?(event.payload)

      e = ActiveSupport::DeprecationException.new(event.payload[:message])
      e.set_backtrace(event.payload[:callstack].map(&:to_s))
      raise e
    end
  end
end
