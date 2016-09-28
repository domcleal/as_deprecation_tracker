# frozen_string_literal: true
require 'test_helper'

class RailtieTest < ASDeprecationTracker::TestCase
  def test_deprecation_behavior
    assert_equal [ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]], ActiveSupport::Deprecation.behavior
  end
end
