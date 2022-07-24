# frozen_string_literal: true

module ASDeprecationTracker
  # Configuration of a whitelisted (known) deprecation warning matched by data
  # such as a message and/or callstack
  class WhitelistEntry
    KNOWN_KEYS = %w[callstack engine message].freeze
    MESSAGE_CLEANUP_RE = Regexp.new('\ADEPRECATION WARNING: (.+) \(called from.*')
    CALLSTACK_FILE_RE = Regexp.new('\A(.*?)(?::(\d+))?(?::in `(.+)\')?\z')

    def initialize(callstack: [], engine: nil, message: nil)
      @callstack = callstack_to_files_lines(Array.wrap(callstack))
      @engine_root = engine.present? ? engine_root(engine) : nil
      @message = message
    end

    def matches?(deprecation)
      return false if @message.present? && !message_matches?(deprecation[:message])
      return false if @callstack.present? && !callstack_matches?(deprecation[:callstack])
      return false if @engine_root.present? && !engine_root_matches?(deprecation[:callstack])

      true
    end

    private

    def message_matches?(message)
      clean_message(message).start_with?(@message)
    end

    def clean_message(message)
      cleanup_match = MESSAGE_CLEANUP_RE.match(message)
      cleanup_match ? cleanup_match[1] : message
    end

    def callstack_to_files_lines(callstack)
      callstack.map do |entry|
        file_match = CALLSTACK_FILE_RE.match(entry)
        [file_match[1], file_match[2].nil? ? nil : file_match[2].to_i, file_match[3]]
      end
    end

    def callstack_matches?(callstack)
      # Call #to_s to replace Thread::Backtrace::Location instances
      callstack = Rails::BacktraceCleaner.new.clean(callstack.map(&:to_s), :silent)
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

    def engine_root_matches?(callstack)
      callstack.any? { |callstack_entry| callstack_entry.to_s.start_with?(@engine_root) }
    end

    def engine_root(engine_name)
      ::Rails::Engine.descendants.each do |engine|
        begin
          return engine.root.to_s if engine_name.to_s == engine.engine_name.to_s
        rescue NoMethodError, RuntimeError
          # Ignore failures with singleton engine subclasses etc.
        end
      end
      raise("Unknown configured engine name #{engine_name}")
    end
  end
end
