# frozen_string_literal: true
require 'test_helper'

class WhitelistEntryTest < ASDeprecationTracker::TestCase
  def test_initialize_with_strings
    ASDeprecationTracker::WhitelistEntry.new('message' => 'test')
  end

  def test_initialize_with_symbols
    ASDeprecationTracker::WhitelistEntry.new(message: 'test')
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

  def test_matches_different_message_same_callstack
    refute entry.matches?(deprecation(message: 'a different method is deprecated'))
  end

  def test_matches_same_message_different_callstack
    refute entry.matches?(deprecation(callstack: caller))
  end

  def test_matches_different_message_different_callstack
    refute entry.matches?(deprecation(message: 'a different method is deprecated', callstack: caller))
  end

  private

  def deprecation(overrides = {})
    {
      message: 'uniq is deprecated and will be removed',
      callstack: [
        '/home/user/app/models/foo.rb:23'
      ]
    }.merge(overrides).compact
  end

  def entry(overrides = {})
    ASDeprecationTracker::WhitelistEntry.new(deprecation(overrides))
  end
end
