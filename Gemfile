# frozen_string_literal: true

source 'https://rubygems.org'

rails_version = if ENV.key?('RAILS_VERSION')
                  if ENV['RAILS_VERSION'].start_with?('git:')
                    { github: 'rails/rails', branch: ENV['RAILS_VERSION'].sub('git:', '') }
                  else
                    "~> #{ENV['RAILS_VERSION']}"
                  end
                else
                  '>= 4.2'
                end

gem 'activesupport', rails_version
gem 'nokogiri', '< 1.7' if RUBY_VERSION.start_with?('2.0.0')
gem 'railties', rails_version

group :test do
  gem 'combustion', '~> 0.5', require: false
  # mocha ~> 1.1's minitest integration references the old `MiniTest` (capital T)
  # constant, which predates minitest 5.0's 2013 rename to `Minitest`. minitest
  # kept `MiniTest` defined as a compat alias through 5.18, but no longer does by
  # default starting in 5.19.
  gem 'minitest', '~> 5.0', '< 5.19', require: false
  gem 'mocha', '~> 1.1', require: false
  gem 'rake'
  gem 'rubocop', '~> 1.32.0', require: false
end
