# frozen_string_literal: true

require 'test_helper'

class ConfigurationTest < ASDeprecationTracker::TestCase
  def test_envs
    assert_equal ['test'], config.envs
  end

  def test_envs=
    config.envs = ['development']
    assert_equal ['development'], config.envs
  end

  def test_line_tolerance
    assert_equal 10, config.line_tolerance
  end

  def test_line_tolerance=
    config.line_tolerance = 42
    assert_equal 42, config.line_tolerance
  end

  def test_register_behavior?
    assert_equal true, config.register_behavior?
  end

  def test_running_with_disable_true
    with_env(AS_DEPRECATION_DISABLE: 'true') do
      assert_equal false, config.register_behavior?
    end
  end

  def test_register_behavior=
    config.register_behavior = false
    assert_equal false, config.register_behavior?
  end

  def test_whitelist_file
    assert_kind_of String, config.whitelist_file
    assert File.exist?(File.join(Rails.root, config.whitelist_file))
  end

  def test_whitelist_file=
    config.whitelist_file = 'another_file.yaml'
    assert_equal 'another_file.yaml', config.whitelist_file
  end

  private

  def config
    @config ||= ASDeprecationTracker::Configuration.new
  end
end
