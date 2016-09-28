module ASDeprecationTracker
  require 'as_deprecation_tracker/configuration'
  require 'as_deprecation_tracker/version'

  def self.config
    @config ||= Configuration.new
  end
end
