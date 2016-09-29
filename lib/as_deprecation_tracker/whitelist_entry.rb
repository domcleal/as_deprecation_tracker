# frozen_string_literal: true
module ASDeprecationTracker
  # Configuration of a whitelisted (known) deprecation warning matched by data
  # such as a message and/or callstack
  class WhitelistEntry
    MESSAGE_CLEANUP_RE = Regexp.new('\ADEPRECATION WARNING: (.+) \(called from.*')
    CALLSTACK_FILE_RE = Regexp.new('\A(.*):(\d+)\z')

    def initialize(entry)
      entry = entry.with_indifferent_access
      raise('Missing `message` or `callstack` from whitelist entry') unless entry.key?(:message) || entry.key?(:callstack)
      @message = entry[:message]
      @callstack = callstack_to_files_lines(Array.wrap(entry[:callstack]))
    end

    def matches?(deprecation)
      Rails.logger.debug("Comparing #{@message.inspect} with #{deprecation[:message].inspect}")
      return false if @message.present? && !message_matches?(deprecation[:message])
      return false if @callstack.present? && !callstack_matches?(deprecation[:callstack])
      true
    end

    private

    def message_matches?(message)
      cleanup_match = MESSAGE_CLEANUP_RE.match(message)
      message = cleanup_match[1] if cleanup_match
      message == @message
    end

    def callstack_to_files_lines(callstack)
      callstack.map do |entry|
        file_match = CALLSTACK_FILE_RE.match(entry)
        file_match ? [file_match[1], file_match[2].to_i] : [entry]
      end
    end

    def callstack_matches?(callstack)
      callstack = callstack_to_files_lines(callstack)

      @callstack.all? do |whitelist_entry|
        callstack_entry_matches?(whitelist_entry, callstack)
      end
    end

    def callstack_entry_matches?(whitelist_entry, callstack)
      callstack.any? do |callstack_entry|
        if whitelist_entry.size == 1
          callstack_entry.first == whitelist_entry.first
        else
          callstack_entry.first == whitelist_entry.first &&
            line_number_within_tolerance(callstack_entry.second, whitelist_entry.second)
        end
      end
    end

    def line_number_within_tolerance(line1, line2)
      (line1 - line2).abs <= ASDeprecationTracker.config.line_tolerance
    end
  end
end
