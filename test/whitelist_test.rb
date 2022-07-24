# frozen_string_literal: true

require 'test_helper'

class WhitelistTest < ASDeprecationTracker::TestCase
  def setup
    @whitelist = ASDeprecationTracker::Whitelist.new
    super
  end

  def test_add
    @whitelist.add(entry)
    assert_equal 1, @whitelist.list.count
  end

  def test_add_to_list
    @whitelist.add_to_list([entry])
    assert_equal 1, @whitelist.list.count
  end

  def test_add_to_list_string_keys
    @whitelist.add_to_list([entry.stringify_keys])
    assert_equal 1, @whitelist.list.count
  end

  def test_clear
    @whitelist.add_to_list([entry])
    @whitelist.clear
    assert @whitelist.list.empty?
  end

  def test_load_file
    File.expects(:read).with('root/config/as_deprecation_whitelist.yaml').returns("---\n- :message: test\n")
    @whitelist.load_file('root/config/as_deprecation_whitelist.yaml')
    assert_equal 1, @whitelist.list.count
  end

  def test_load_file_empty
    File.expects(:read).with('root/config/as_deprecation_whitelist.yaml').returns('---')
    @whitelist.load_file('root/config/as_deprecation_whitelist.yaml')
    assert_equal 0, @whitelist.list.count
  end

  def test_matches_failure
    @whitelist.add_to_list([entry])
    deprecation = mock('deprecation')
    @whitelist.list.first.expects(:matches?).with(deprecation).returns(false)
    refute @whitelist.matches?(deprecation)
  end

  def test_matches_success
    @whitelist.add_to_list([entry])
    deprecation = mock('deprecation')
    @whitelist.list.first.expects(:matches?).with(deprecation).returns(true)
    assert @whitelist.matches?(deprecation)
  end

  private

  def entry
    { message: 'deprecated call', callstack: caller }
  end
end
