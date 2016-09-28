# frozen_string_literal: true
require 'test_helper'

class ConfigurationTest < ASDeprecationTracker::TestCase
  def setup
    @config = ASDeprecationTracker::Configuration.new
    super
  end

  def test_envs
    assert_equal ['test'], @config.envs
  end

  def test_envs=
    @config.envs = ['development']
    assert_equal ['development'], @config.envs
  end
end
