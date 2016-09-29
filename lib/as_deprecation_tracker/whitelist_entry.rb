# frozen_string_literal: true
module ASDeprecationTracker
  # Configuration of a whitelisted (known) deprecation warning matched by data
  # such as a message and/or callstack
  class WhitelistEntry
    MESSAGE_CLEANUP_RE = Regexp.new('\ADEPRECATION WARNING: (.+) \(called from.*')

    def initialize(entry)
      entry = entry.with_indifferent_access
      raise('Missing `message` or `callstack` from whitelist entry') unless entry.key?(:message) || entry.key?(:callstack)
      @message = entry[:message]
      @callstack = entry[:callstack]
    end

    def matches?(deprecation)
      Rails.logger.debug("Comparing #{@message.inspect} with #{deprecation[:message].inspect}")
      return false if @message.present? && !message_matches?(deprecation[:message])
      return false if @callstack.present? && deprecation[:callstack] != @callstack
      true
    end

    private

    def message_matches?(message)
      cleanup_match = MESSAGE_CLEANUP_RE.match(message)
      message = cleanup_match[1] if cleanup_match
      message == @message
    end
  end
end
