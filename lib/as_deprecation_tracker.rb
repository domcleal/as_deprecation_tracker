# frozen_string_literal: true
# Entry point, provides constant with access to global configuration only
module ASDeprecationTracker
  require 'as_deprecation_tracker/configuration'
  require 'as_deprecation_tracker/version'

  def self.config
    @config ||= Configuration.new
  end
end
