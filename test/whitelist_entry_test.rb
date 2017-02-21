# frozen_string_literal: true
require 'test_helper'

class WhitelistEntryTest < ASDeprecationTracker::TestCase
  def test_initialize_with_strings
    ASDeprecationTracker::WhitelistEntry.new('message' => 'test')
  end

  def test_initialize_with_symbols
    ASDeprecationTracker::WhitelistEntry.new(message: 'test')
  end

  def test_initialize_with_empty_hash
    assert_raises(RuntimeError) { ASDeprecationTracker::WhitelistEntry.new({}) }
  end

  def test_initialize_with_unknown_keys
    assert_raises(RuntimeError) { ASDeprecationTracker::WhitelistEntry.new(unknown: 'test') }
  end

  def test_matches_message_and_callstack
    assert entry.matches?(deprecation)
  end

  def test_matches_message_with_surrounding_content
    assert entry.matches?(deprecation(message: 'DEPRECATION WARNING: uniq is deprecated and will be removed (called from block in <class:Foo> at app/models/foo.rb:23)'))
  end

  def test_matches_message_only
    assert entry(callstack: nil).matches?(deprecation(callstack: caller))
  end

  def test_matches_callstack_only
    assert entry(message: nil).matches?(deprecation)
  end

  def test_matches_partial_callstack_top
    assert entry(callstack: ['app/models/foo.rb:23']).matches?(deprecation)
  end

  def test_matches_partial_callstack_bottom
    assert entry(callstack: ['app/controllers/foos_controller.rb:42']).matches?(deprecation)
  end

  def test_matches_partial_callstack_multiple
    assert entry(callstack: [
                   'app/models/foo.rb:23',
                   'app/controllers/foos_controller.rb:42'
                 ]).matches?(deprecation)
  end

  def test_matches_partial_callstack_within_tolerance
    assert entry(callstack: ['app/models/foo.rb:25']).matches?(deprecation)
  end

  def test_matches_partial_callstack_outside_tolerance
    refute entry(callstack: ['app/models/foo.rb:34']).matches?(deprecation)
  end

  def test_matches_partial_callstack_same_method
    assert entry(callstack: ['app/models/foo.rb:in `example_method\'']).matches?(deprecation)
  end

  def test_matches_partial_callstack_different_method
    refute entry(callstack: ['app/models/foo.rb:23:in `another_method\'']).matches?(deprecation)
  end

  def test_matches_partial_callstack_different_method_no_line
    refute entry(callstack: ['app/models/foo.rb:in `another_method\'']).matches?(deprecation)
  end

  def test_matches_partial_callstack_within_tolerance_same_method
    assert entry(callstack: ['app/models/foo.rb:25:in `example_method\'']).matches?(deprecation)
  end

  def test_matches_partial_callstack_outside_tolerance_same_method
    refute entry(callstack: ['app/models/foo.rb:34:in `example_method\'']).matches?(deprecation)
  end

  def test_matches_partial_callstack_string
    assert entry(callstack: 'app/models/foo.rb:23').matches?(deprecation)
  end

  def test_matches_partial_callstack_file
    assert entry(callstack: ['app/models/foo.rb']).matches?(deprecation)
  end

  def test_matches_different_message_same_callstack
    refute entry.matches?(deprecation(message: 'a different method is deprecated'))
  end

  def test_matches_same_message_different_callstack
    refute entry.matches?(deprecation(callstack: caller))
  end

  def test_matches_different_message_different_callstack
    refute entry.matches?(deprecation(message: 'a different method is deprecated', callstack: caller))
  end

  def test_matches_only_engine
    assert entry(engine: 'example').matches?(deprecation(called_in_engine: 'example'))
  end

  def test_matches_different_engine
    refute entry(engine: 'another').matches?(deprecation(called_in_engine: 'example'))
  end

  def test_matches_outside_engine
    refute entry(engine: 'another').matches?(deprecation(called_in_engine: 'example'))
  end

  private

  def default_deprecation
    {
      message: 'uniq is deprecated and will be removed',
      callstack: [
        "#{Rails.root}/app/models/foo.rb:23:in `example_method'",
        "#{Rails.root}/app/controllers/foos_controller.rb:42:in `update'",
        "#{Rails.root}/test/controllers/foos_controller_test.rb:18:in `block in <class:FoosControllerTest>'"
      ]
    }
  end

  def deprecation(overrides = {})
    deprecation = default_deprecation
    if (engine = overrides.delete(:called_in_engine))
      deprecation[:callstack] << "/home/user/engines/#{engine}/app/middleware/foo.rb:12:in `call'"
    end
    deprecation.merge(overrides).compact
  end

  def entry(overrides = {})
    entry_hash = default_deprecation.merge(overrides).compact
    entry_hash[:callstack].map! { |line| line.sub(Rails.root.to_s + '/', '') } if entry_hash[:callstack].is_a?(Array)

    ASDeprecationTracker::WhitelistEntry.any_instance.expects(:engine_root).with(overrides[:engine]).returns("/home/user/engines/#{overrides[:engine]}") if overrides.key?(:engine)
    ASDeprecationTracker::WhitelistEntry.new(entry_hash)
  end
end
