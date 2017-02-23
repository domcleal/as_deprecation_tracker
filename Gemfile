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
gem 'railties', rails_version

group :test do
  gem 'combustion', '~> 0.5', require: false
  gem 'minitest', '~> 5.0', require: false
  gem 'mocha', '~> 1.1', require: false
  gem 'rake'
  gem 'rubocop', '~> 0.47.1', require: false
end
