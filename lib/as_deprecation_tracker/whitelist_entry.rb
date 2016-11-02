# frozen_string_literal: true
module ASDeprecationTracker
  # Configuration of a whitelisted (known) deprecation warning matched by data
  # such as a message and/or callstack
  class WhitelistEntry
    KNOWN_KEYS = %w(callstack message).freeze
    MESSAGE_CLEANUP_RE = Regexp.new('\ADEPRECATION WARNING: (.+) \(called from.*')
    CALLSTACK_FILE_RE = Regexp.new('\A(.*?)(?::(\d+))?(?::in `(.+)\')?\z')

    def initialize(entry)
      entry = entry.with_indifferent_access
      validate_keys! entry
      @message = entry[:message]
      @callstack = callstack_to_files_lines(Array.wrap(entry[:callstack]))
    end

    def matches?(deprecation)
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
        [file_match[1], file_match[2].nil? ? nil : file_match[2].to_i, file_match[3]]
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
        callstack_entry[0] == whitelist_entry[0] &&
          line_number_within_tolerance(callstack_entry[1], whitelist_entry[1]) &&
          method_name_matches(callstack_entry[2], whitelist_entry[2])
      end
    end

    def line_number_within_tolerance(line1, line2)
      return true if line1.nil? || line2.nil?
      (line1 - line2).abs <= ASDeprecationTracker.config.line_tolerance
    end

    def method_name_matches(method1, method2)
      return true if method1.nil? || method2.nil?
      method1 == method2
    end

    def validate_keys!(entry)
      raise("Missing #{KNOWN_KEYS.join(', ')} from whitelist entry") unless KNOWN_KEYS.any? { |key| entry.key?(key) }
      unknown_keys = entry.keys - KNOWN_KEYS
      raise("Unknown configuration key(s) #{unknown_keys.join(', ')}") unless unknown_keys.empty?
    end
  end
end
