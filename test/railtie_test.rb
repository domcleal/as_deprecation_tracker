# frozen_string_literal: true

require 'test_helper'

class RailtieTest < ASDeprecationTracker::TestCase
  def test_deprecation_behavior
    behavior = if Rails.application.respond_to?(:deprecators)
                 ActiveSupport.deprecator.behavior
               else
                 ActiveSupport::Deprecation.behavior
               end
    assert_equal [ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]], behavior
  end
end
