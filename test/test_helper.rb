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

# WebMock intercepts HTTP; it does not intercept DNS. Recipes::PageFetcher
# resolves the hostname *before* opening the connection, to refuse SSRF targets,
# so on a machine with no DNS its six tests failed with the request never
# attempted — the guard working exactly as designed, on a question those tests
# had not meant to ask.
#
# The stub keeps the guard honest rather than switching it off: a literal IP
# resolves to itself, so the loopback and cloud-metadata cases are still
# refused for the real reason. Only a *name* short-circuits, to the one thing
# a test that stubbed example.com already means by it — a public host.
Recipes::PageFetcher.resolver = lambda do |host|
  IPAddr.new(host.to_s) # raises unless the host is already an address
  [ host.to_s ]
rescue IPAddr::InvalidAddressError
  [ "93.184.216.34" ] # example.com, per IANA's reserved documentation range
end

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

    # Rails.cache itself stays a null store here, so that a test asserting a
    # cache actually works has to say so — and so that a test *not* about
    # caching can never pass because of a value another test left behind.
    def with_cache
      previous = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      yield
    ensure
      Rails.cache = previous
    end

    # ── Locale-independent assertions ────────────────────────────────────
    # Spelling an expected string in English asserts, silently, that the suite
    # runs in English — which is not what any of these tests mean, and is what
    # made 93 of them fail under `LOCALE=fr bin/rails test` while the app was
    # behaving perfectly.
    #
    # The two helpers below resolve the same string Rails would build, through
    # I18n, so the assertion says "the error for a blank name" rather than
    # "the seven characters c-a-n-'-t-...".

    # The bare message, as it appears inside `record.errors[:attribute]`.
    def error_message(key, **options)
      I18n.t("errors.messages.#{key}", **options)
    end

    # The full sentence, as it reaches a flash: "Name can't be blank".
    def validation_message(model_class, attribute, key = :blank, **options)
      I18n.t("errors.format",
        attribute: model_class.human_attribute_name(attribute),
        message: error_message(key, **options))
    end

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    # Asserts that a translated string reaches the rendered page.
    #
    # `assert_includes @response.body, I18n.t(...)` is not enough: the body is
    # HTML, so "Aucune pesée pour l'instant." is written "l&#39;instant" in it.
    # The English literals these assertions used to carry never hit that,
    # which is one more way of saying they only ever tested one locale.
    def assert_body_includes(text, message = nil)
      assert_includes @response.body, ERB::Util.html_escape(text).to_s, message
    end

    def assert_body_excludes(text, message = nil)
      assert_not_includes @response.body, ERB::Util.html_escape(text).to_s, message
    end
  end
end
