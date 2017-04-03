# frozen_string_literal: true
# Entry point, provides constant with access to global configuration only
module ASDeprecationTracker
  require 'as_deprecation_tracker/configuration'
  require 'as_deprecation_tracker/railtie'
  require 'as_deprecation_tracker/version'
  require 'as_deprecation_tracker/whitelist'

  def self.active?
    config.envs.include?(Rails.env)
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.pause!
    @paused = true
  end

  def self.receiver
    @receiver ||= Receiver.new
  end

  def self.resume!
    @paused = false
    @receiver.try!(:process_queue)
  end

  def self.running?
    ENV['AS_DEPRECATION_DISABLE'].nil? && !@paused
  end

  def self.whitelist
    @whitelist ||= Whitelist.new
  end
end
