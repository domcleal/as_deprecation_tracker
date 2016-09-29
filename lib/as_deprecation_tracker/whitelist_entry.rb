# frozen_string_literal: true
module ASDeprecationTracker
  # Configuration of a whitelisted (known) deprecation warning matched by data
  # such as a message and/or callstack
  class WhitelistEntry
    def initialize(entry)
      entry = entry.with_indifferent_access
      raise('Missing `message` or `callstack` from whitelist entry') unless entry.key?(:message) || entry.key?(:callstack)
      @message = entry[:message]
      @callstack = entry[:callstack]
    end

    def matches?(deprecation)
      return false if @message.present? && deprecation[:message] != @message
      return false if @callstack.present? && deprecation[:callstack] != @callstack
      true
    end
  end
end
