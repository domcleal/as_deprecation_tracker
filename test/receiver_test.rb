# frozen_string_literal: true
require 'test_helper'

class ReceiverTest < ASDeprecationTracker::TestCase
  def test_deprecation_when_running
    ASDeprecationTracker.expects(:running?).returns(true)
    receiver = ASDeprecationTracker::Receiver.new
    event = mock('event')
    receiver.expects(:process_event).with(event)
    receiver.deprecation(event)
  end

  def test_deprecation_when_not_running
    ASDeprecationTracker.expects(:running?).returns(false)
    receiver = ASDeprecationTracker::Receiver.new
    event = mock('event')
    receiver.expects(:process_event).never
    receiver.deprecation(event)
  end

  def test_process_event_whitelisted
    whitelist = ASDeprecationTracker::Whitelist.new
    ASDeprecationTracker.expects(:whitelist).returns(whitelist)
    stack = caller
    whitelist.expects(:matches?).with(message: 'deprecated call', callstack: stack).returns(true)
    ASDeprecationTracker::Receiver.new.process_event(event(message: 'deprecated call', callstack: stack))
  end

  def test_process_event_unknown
    whitelist = ASDeprecationTracker::Whitelist.new
    ASDeprecationTracker.expects(:whitelist).returns(whitelist)
    stack = caller
    whitelist.expects(:matches?).with(message: 'deprecated call', callstack: stack).returns(false)
    e = assert_raises(ActiveSupport::DeprecationException) do
      ASDeprecationTracker::Receiver.new.process_event(event(message: 'deprecated call', callstack: stack))
    end
    assert_equal 'deprecated call', e.message
    assert_equal stack, e.backtrace
  end

  def test_process_event_unknown_record
    whitelist = ASDeprecationTracker::Whitelist.new
    ASDeprecationTracker.expects(:whitelist).twice.returns(whitelist)
    stack = caller
    whitelist.expects(:matches?).with(message: 'deprecated call', callstack: stack).returns(false)
    whitelist.expects(:add).with(message: 'deprecated call', callstack: stack.first)
    ASDeprecationTracker::Writer.any_instance.expects(:add).with('deprecated call', stack).returns(message: 'deprecated call', callstack: stack.first)
    ASDeprecationTracker::Writer.any_instance.expects(:write_file)
    with_env(AS_DEPRECATION_RECORD: 'true') do
      ASDeprecationTracker::Receiver.new.process_event(event(message: 'deprecated call', callstack: stack))
    end
  end

  def test_process_queue
    ASDeprecationTracker.expects(:running?).returns(false)
    receiver = ASDeprecationTracker::Receiver.new
    event = mock('event')
    receiver.deprecation(event)
    receiver.expects(:process_event).with(event)
    receiver.process_queue
  end

  def test_subscription
    ASDeprecationTracker::Receiver.any_instance.expects(:deprecation)
    ActiveSupport::Notifications.instrument('deprecation.rails', message: 'test')
  end

  def test_whitelist_file_root
    assert_equal File.join(Rails.root, 'config', 'as_deprecation_whitelist.yaml'), ASDeprecationTracker::Receiver.new.send(:whitelist_file)
  end

  def test_whitelist_file_env_directory
    ENV['AS_DEPRECATION_WHITELIST'] = '/'
    assert_equal File.join('/', 'config', 'as_deprecation_whitelist.yaml'), ASDeprecationTracker::Receiver.new.send(:whitelist_file)
  ensure
    ENV.delete('AS_DEPRECATION_WHITELIST')
  end

  def test_whitelist_file_env_file
    ENV['AS_DEPRECATION_WHITELIST'] = '/as_deprecation_whitelist.yaml'
    assert_equal '/as_deprecation_whitelist.yaml', ASDeprecationTracker::Receiver.new.send(:whitelist_file)
  ensure
    ENV.delete('AS_DEPRECATION_WHITELIST')
  end

  def test_whitelist_file_env_expand
    ENV['AS_DEPRECATION_WHITELIST'] = File.join(Rails.root, '..', 'as_deprecation_whitelist.yaml')
    assert_equal File.expand_path('../as_deprecation_whitelist.yaml', Rails.root), ASDeprecationTracker::Receiver.new.send(:whitelist_file)
  ensure
    ENV.delete('AS_DEPRECATION_WHITELIST')
  end

  private

  def event(payload)
    mock('event').tap do |event|
      event.stubs(:payload).returns(payload)
    end
  end
end
