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
require_relative "test_helpers/system_test_helper"

# No real network calls in tests (Open Food Facts, Nominatim...): every test must
# explicitly stub the requests it exercises.
WebMock.disable_net_connect!(allow_localhost: true)

module ActiveSupport
  class TestCase
    # `pg` (1.6.3-arm64-darwin) segfaults as soon as a forked worker opens its
    # own connection (PG::Connection#connect_start) — every open pg socket's
    # underlying state is corrupted by fork on this platform, which hangs the
    # whole run until killed. CI (Linux) forks fine, so only skip it here.
    if RUBY_PLATFORM.match?(/arm64-darwin/)
      parallelize(workers: 1)
    else
      parallelize(workers: :number_of_processors)
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # `rate_limit` counters live in the controller cache store, which the test
    # environment points at a real in-memory store so limits can be asserted at
    # all. That store outlives an individual test, and every test drives the app
    # from the same 127.0.0.1, so without this the suite would share one counter
    # per limit and start tripping its own rate limits as it grew.
    setup { ActionController::Base.cache_store.clear }

    # Add more helper methods to be used by all tests here...
  end
end
