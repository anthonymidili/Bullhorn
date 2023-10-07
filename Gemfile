source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.4'
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
# gem 'puma', '~> 3.12'
gem 'passenger', '>= 5.0.25', require: 'phusion_passenger/rack_handler'
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# Background Jobs
gem 'sidekiq', '~> 7.1.2'
gem 'redis', '~> 5.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# JavaScript Bundling for Rails
gem "jsbundling-rails", "~> 1.1"
# CSS Bundling for Rails
gem "cssbundling-rails", "~> 1.1"

# Use ActiveStorage variant
gem "ruby-vips"
gem 'image_processing', '~> 1.6'
gem 'aws-sdk-s3', require: false
# Validate images
gem 'file_validators'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
# Haml and haml generator
gem 'haml-rails', '~> 2.0'
# devise
gem 'devise', '~> 4.9.0'
# pagination
gem 'kaminari', '~> 1.2.1'
# https://github.com/nathanvda/cocoon - Dynamic nested forms using jQuery
gem 'cocoon', '~> 1.2.8'
# https://github.com/thoughtbot/scenic - Scenic adds methods to
# ActiveRecord::Migration to create and manage database views in Rails.
gem 'scenic', '~> 1.7.0'
# framework-agnostic XML Sitemap generator
gem 'sitemap_generator'

gem 'simple_calendar', '~> 3.0'
gem 'sib-api-v3-sdk'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Better Errors
  gem 'better_errors'
  gem 'binding_of_caller'

  # Add console tables with Hirb.enable.
  # gem 'hirb'
  # IRB colors.
  # gem 'irbtools', require: 'irbtools/binding'

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  # gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.2.0'
    # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.0'
  # N+1 finder
  gem 'bullet'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
