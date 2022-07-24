# frozen_string_literal: true

module ASDeprecationTracker
  # Maintains configuration for one instance (usually global)
  class Configuration
    attr_accessor :envs, :line_tolerance, :register_behavior, :whitelist_file
    alias register_behavior? register_behavior

    def initialize
      @envs = %w[test]
      @line_tolerance = 10
      @register_behavior = ASDeprecationTracker.env('DISABLE').nil?
      @whitelist_file = File.join('config', 'as_deprecation_whitelist.yaml')
    end
  end
end
