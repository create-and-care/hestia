require "simplecov"
SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/config/"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require_relative "test_helpers/session_test_helper"

# No real network calls in tests (Open Food Facts, Nominatim...): every test must
# explicitly stub the requests it exercises.
WebMock.disable_net_connect!(allow_localhost: true)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
