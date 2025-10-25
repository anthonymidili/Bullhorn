source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.4"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.1.0"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft", "~> 1.3.1"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
# gem 'puma', '~> 3.12'
gem "passenger", "~> 6.0", ">= 6.0.18"
# Fiddle is an extension to translate a foreign function interface (FFI) with ruby.
gem "fiddle", "~> 1.1.8"
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# Background Jobs
gem "sidekiq", "~> 8.0.7"
gem "redis", "~> 5.0"
# Use kredis encapsulates higher-level types and
# data structures around a single key for Redis
gem "kredis", "~>1.8.0"
# Cron like jobs
gem "sidekiq-scheduler", "~> 6.0.1"
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
gem "image_processing", "~> 1.6"
gem "aws-sdk-s3", require: false

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false
# Haml and haml generator
gem "haml-rails", "~> 3.0"
# devise
gem "devise", "~> 4.9.0"
# pagination
gem "kaminari", "~> 1.2.1"
# https://github.com/nathanvda/cocoon - Dynamic nested forms using jQuery
gem "cocoon", "~> 1.2.8"
# https://github.com/thoughtbot/scenic - Scenic adds methods to
# ActiveRecord::Migration to create and manage database views in Rails.
# gem 'scenic', '~> 1.7.0'
# framework-agnostic XML Sitemap generator
gem "sitemap_generator"

gem "simple_calendar", "~> 3.0"
gem "sib-api-v3-sdk"

# Add console tables with Hirb.enable.
gem "hirb", "~> 0.7.3"

group :development, :test do
  # Call 'binding.b or debugger' anywhere in the code to stop execution and get a debugger console
  gem "debug", ">= 1.0.0"
end

group :development do
  # IRB colors.
  gem "irbtools", require: "irbtools/binding"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", "~> 3.3"
  gem "better_errors"
  gem "binding_of_caller"
  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false
  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  gem "dotenv-rails", "~> 3.1.8"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", "~> 1.2025" if Gem.win_platform?
