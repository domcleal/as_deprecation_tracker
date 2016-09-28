# frozen_string_literal: true
module ASDeprecationTracker
  # Maintains configuration for one instance (usually global)
  class Configuration
    attr_accessor :envs, :register_behavior
    alias register_behavior? register_behavior

    def initialize
      @envs = %w(test)
      @register_behavior = true
    end
  end
end
