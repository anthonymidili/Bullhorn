ENV["RAILS_ENV"] ||= "test"

# Ensure test directory is in load path for requiring test_helper
test_dir = File.expand_path(__dir__)
$LOAD_PATH.unshift(test_dir) unless $LOAD_PATH.include?(test_dir)

require_relative "../config/environment"
require "rails/test_help"
require "active_job/test_helper"

module ActiveSupport
  class TestCase
    # Run tests serially to avoid issues with parallel test execution
    # Note: Rails 8.1.x has a known issue where `bin/rails test` doesn't load test files properly.
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include Devise::Test::IntegrationHelpers
    include ActiveJob::TestHelper
  end
end

begin
  require "capybara/minitest"
  class ActionDispatch::SystemTestCase
    # Default to `:rack_test` to avoid automatic Selenium/driver resolution
    # (which triggers webdrivers network activity). Enable Selenium-driven
    # system tests by setting `SYSTEM_TESTS=true` in your environment.
    if ENV["SYSTEM_TESTS"] == "true"
      driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
    else
      driven_by :rack_test
    end
  end
rescue LoadError, Selenium::WebDriver::Error::NoSuchDriverError => e
  # Capybara not available or ChromeDriver not found; system tests will be skipped.
  # Silently skip system tests if dependencies are missing.
end
