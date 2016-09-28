# frozen_string_literal: true
require 'test_helper'

class ASDeprecationTrackerTest < Minitest::Test
  def test_config_returns_configuration
    assert_kind_of ASDeprecationTracker::Configuration, ASDeprecationTracker.config
  end

  def test_config_returns_same_configuration
    config = ASDeprecationTracker.config
    assert_equal config, ASDeprecationTracker.config
  end
end
