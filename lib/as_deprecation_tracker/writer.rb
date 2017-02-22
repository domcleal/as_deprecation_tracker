# frozen_string_literal: true
require 'as_deprecation_tracker/whitelist_entry'
require 'rails/backtrace_cleaner'

module ASDeprecationTracker
  # Rewrites the whitelist configuration file to append new observed entries
  class Writer
    def initialize(filename)
      @filename = filename
      @contents = []
      @contents = YAML.safe_load(File.read(filename), [Symbol]) || [] if File.exist?(filename)
    end

    def add(message, callstack)
      cleanup_match = WhitelistEntry::MESSAGE_CLEANUP_RE.match(message)
      message = cleanup_match[1] if cleanup_match

      callstack = Rails::BacktraceCleaner.new.clean(callstack, :silent)

      entry = { 'message' => message, 'callstack' => callstack.first }
      @contents << entry
      entry
    end

    def contents
      @contents.sort_by { |e| e.values_at('message', 'callstack').compact }.to_yaml
    end

    def write_file
      File.write(@filename, contents)
    end
  end
end
