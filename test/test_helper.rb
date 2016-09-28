# frozen_string_literal: true
require 'minitest/autorun'
require 'combustion'

Combustion.path = 'test/internal'
Combustion.initialize!

require 'as_deprecation_tracker'

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
