# frozen_string_literal: true
require 'minitest/autorun'
require 'mocha/mini_test'
require 'combustion'

require 'as_deprecation_tracker'

Combustion.path = 'test/internal'
Combustion.initialize!

module ASDeprecationTracker
  class TestCase < ::Minitest::Test; end
end
