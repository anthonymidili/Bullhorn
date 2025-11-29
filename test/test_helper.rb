ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include Devise::Test::IntegrationHelpers
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
