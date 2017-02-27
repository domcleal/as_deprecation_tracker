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
    @running = false
  end

  def self.receiver
    @receiver ||= Receiver.new
  end

  def self.resume!
    @running = true
    @receiver.try!(:process_queue)
  end

  def self.running?
    @running.nil? || @running
  end

  def self.whitelist
    @whitelist ||= Whitelist.new
  end
end
