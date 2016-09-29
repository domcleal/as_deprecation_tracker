# frozen_string_literal: true
require File.expand_path('../lib/as_deprecation_tracker/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'as_deprecation_tracker'
  s.version = ASDeprecationTracker::VERSION

  s.summary = 'Track known ActiveSupport deprecation warnings'
  s.description = 'Tracks known ActiveSupport (Rails) deprecation warnings and catches new issues when an unknown warning is seen.'

  s.authors = ['Dominic Cleal']
  s.email = 'dominic@cleal.org'
  s.homepage = 'https://github.com/domcleal/as_deprecation_tracker'
  s.license = 'MIT'
  s.require_paths = ['lib']

  s.files = `git ls-files`.split("\n") - Dir['.*', 'Gem*', '*.gemspec']

  s.required_ruby_version '>= 2.0.0'
  s.add_dependency 'activesupport', '>= 4.2'
  s.add_dependency 'railties', '>= 4.2'
end
