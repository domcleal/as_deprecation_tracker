# frozen_string_literal: true
require 'as_deprecation_tracker/whitelist_entry'

module ASDeprecationTracker
  # Stores a list of known and ignored deprecation warnings, and provides a
  # query interface to check if a warning matches the list
  class Whitelist
    attr_reader :list

    def initialize
      @list = []
    end

    def add_to_list(*entries)
      entries.flatten.each { |entry| @list << WhitelistEntry.new(entry.symbolize_keys) }
    end
    alias add add_to_list

    def clear
      @list.clear
    end

    def load_file(path)
      add_to_list(YAML.load(File.read(path)))
    end

    def matches?(deprecation)
      @list.any? { |entry| entry.matches?(deprecation) }
    end
  end
end
