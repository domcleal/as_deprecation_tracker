# frozen_string_literal: true
require 'test_helper'

class ReceiverTest < ASDeprecationTracker::TestCase
  def test_subscription
    ASDeprecationTracker::Receiver.any_instance.expects(:deprecation)
    ActiveSupport::Notifications.instrument('deprecation.rails', message: 'test')
  end
end
