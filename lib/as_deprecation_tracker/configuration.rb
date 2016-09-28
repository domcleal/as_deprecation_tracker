# frozen_string_literal: true
module ASDeprecationTracker
  # Maintains configuration for one instance (usually global)
  class Configuration
    attr_accessor :envs

    def initialize
      @envs = %w(test)
    end
  end
end
