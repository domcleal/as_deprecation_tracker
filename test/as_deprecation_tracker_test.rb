# frozen_string_literal: true
require 'test_helper'

class ASDeprecationTrackerTest < ASDeprecationTracker::TestCase
  def test_active?
    assert ASDeprecationTracker.active?
  end

  def test_active_in_other_env
    ASDeprecationTracker.expects(:config).twice.returns(ASDeprecationTracker::Configuration.new)
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

  def test_pause!
    ASDeprecationTracker.pause!
    refute ASDeprecationTracker.running?
  ensure
    ASDeprecationTracker.resume!
  end

  def test_receiver
    assert_kind_of ASDeprecationTracker::Receiver, ASDeprecationTracker.receiver
    assert_kind_of ActiveSupport::Subscriber, ASDeprecationTracker.receiver
  end

  def test_receiver_returns_same_receiver
    receiver = ASDeprecationTracker.receiver
    assert_equal receiver, ASDeprecationTracker.receiver
  end

  def test_resume!
    ASDeprecationTracker.pause!
    ASDeprecationTracker.receiver.expects(:process_queue)
    ASDeprecationTracker.resume!
    assert ASDeprecationTracker.running?
  end

  def test_running
    assert_equal true, ASDeprecationTracker.running?
  end

  def test_running_with_disable_true
    with_env(AS_DEPRECATION_DISABLE: 'true') do
      assert_equal false, ASDeprecationTracker.running?
    end
  end

  def test_whitelist
    assert_kind_of ASDeprecationTracker::Whitelist, ASDeprecationTracker.whitelist
  end

  def test_whitelist_returns_same_whitelist
    whitelist = ASDeprecationTracker.whitelist
    assert_equal whitelist, ASDeprecationTracker.whitelist
  end
end
