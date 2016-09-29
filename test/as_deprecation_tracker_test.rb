# frozen_string_literal: true
require 'test_helper'

class ASDeprecationTrackerTest < ASDeprecationTracker::TestCase
  def test_active?
    assert ASDeprecationTracker.active?
  end

  def test_active_in_other_env
    ASDeprecationTracker.config.envs = ['development']
    refute ASDeprecationTracker.active?
  end

  def test_config
    assert_kind_of ASDeprecationTracker::Configuration, ASDeprecationTracker.config
  end

  def test_config_returns_same_configuration
    config = ASDeprecationTracker.config
    assert_equal config, ASDeprecationTracker.config
  end

  def test_whitelist
    assert_kind_of ASDeprecationTracker::Whitelist, ASDeprecationTracker.whitelist
  end

  def test_whitelist_returns_same_whitelist
    whitelist = ASDeprecationTracker.whitelist
    assert_equal whitelist, ASDeprecationTracker.whitelist
  end
end
