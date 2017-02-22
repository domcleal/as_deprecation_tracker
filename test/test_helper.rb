# frozen_string_literal: true
require 'minitest/autorun'
require 'mocha/mini_test'
require 'combustion'

require 'as_deprecation_tracker'

Combustion.path = 'test/internal'
Combustion.initialize!

module ASDeprecationTracker
  class TestCase < ::Minitest::Test
    def with_env(new_env)
      new_env.stringify_keys!
      backup = ENV.to_h.slice(new_env.keys)
      begin
        ENV.update(new_env)
        yield
      ensure
        new_env.keys.each { |k| ENV.delete(k) }
        ENV.update(backup)
      end
    end
  end
end
