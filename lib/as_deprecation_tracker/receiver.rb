# frozen_string_literal: true
require 'active_support/subscriber'
require 'as_deprecation_tracker/writer'

module ASDeprecationTracker
  # Receives deprecation.rails events via ActiveSupport::Notifications
  class Receiver < ::ActiveSupport::Subscriber
    def deprecation(event)
      return if ASDeprecationTracker.whitelist.matches?(event.payload)

      message = event.payload[:message]
      callstack = event.payload[:callstack].map(&:to_s)
      if ENV['AS_DEPRECATION_RECORD'].present?
        write_deprecation(message, callstack)
      else
        raise_deprecation(message, callstack)
      end
    end

    private

    def write_deprecation(message, callstack)
      writer = ASDeprecationTracker::Writer.new(ASDeprecationTracker.config.whitelist_file)
      writer.add(message, callstack)
      writer.write_file
    end

    def raise_deprecation(message, callstack)
      e = ActiveSupport::DeprecationException.new(message)
      e.set_backtrace(callstack)
      raise e
    end
  end
end
