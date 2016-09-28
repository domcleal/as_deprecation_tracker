# frozen_string_literal: true
require 'minitest/autorun'
require 'mocha/mini_test'
require 'combustion'

require 'as_deprecation_tracker'

Combustion.path = 'test/internal'
Combustion.initialize!

module ASDeprecationTracker
  def self.reset_config
    @config = nil
  end

  class TestCase < ::Minitest::Test
    def teardown
      ASDeprecationTracker.reset_config
    end
  end
end
