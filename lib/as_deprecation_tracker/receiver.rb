# frozen_string_literal: true

require 'active_support/subscriber'
require 'as_deprecation_tracker/writer'

module ASDeprecationTracker
  # Receives deprecation.rails events via ActiveSupport::Notifications
  class Receiver < ::ActiveSupport::Subscriber
    def initialize
      super
      @event_queue = []
    end

    def deprecation(event)
      @event_queue << event
      process_queue if ASDeprecationTracker.running?
    end

    def process_queue
      process_event(@event_queue.pop) until @event_queue.empty?
    end

    def process_event(event)
      return if ASDeprecationTracker.whitelist.matches?(event.payload)

      message = event.payload[:message]
      callstack = event.payload[:callstack].map(&:to_s)
      if ASDeprecationTracker.env('RECORD').present?
        write_deprecation(message, callstack)
      else
        raise_deprecation(message, callstack)
      end
    end

    private

    def write_deprecation(message, callstack)
      writer = ASDeprecationTracker::Writer.new(whitelist_file)
      entry = writer.add(message, callstack)
      writer.write_file
      ASDeprecationTracker.whitelist.add(entry.symbolize_keys)
    end

    def whitelist_file
      root = if ASDeprecationTracker.env('WHITELIST').present?
               File.expand_path(ASDeprecationTracker.env('WHITELIST'))
             else
               Rails.root
             end

      if File.directory?(root)
        File.join(root, ASDeprecationTracker.config.whitelist_file)
      else
        root
      end
    end

    def raise_deprecation(message, callstack)
      e = ActiveSupport::DeprecationException.new(message)
      e.set_backtrace(callstack)
      raise e
    end
  end
end
