require "test_helper"

class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  # The header exists at all — it was absent for the app's whole life before
  # this, the initializer being commented out end to end.
  test "every response carries an enforcing policy" do
    get new_session_path

    policy = response.headers["Content-Security-Policy"]
    assert policy.present?, "no Content-Security-Policy header"
    assert_nil response.headers["Content-Security-Policy-Report-Only"],
      "the policy is report-only, so it isn't blocking anything"
  end

  test "the policy denies the directives that carry the XSS risk" do
    get new_session_path
    directives = response.headers["Content-Security-Policy"].split(";").map(&:strip).index_by { |d| d.split.first }

    assert_equal "'self'", directives["default-src"].split(" ", 2).last
    assert_equal "'none'", directives["object-src"].split(" ", 2).last
    assert_equal "'self'", directives["form-action"].split(" ", 2).last
    assert_equal "'self'", directives["base-uri"].split(" ", 2).last
    assert_equal "'self'", directives["frame-ancestors"].split(" ", 2).last

    assert_not_includes directives["script-src"], "'unsafe-inline'"
    assert_not_includes directives["script-src"], "'unsafe-eval'"
  end

  # The trap this item was written around: script-src :self kills the inline
  # anti-FOUC script in the layout head, and dark mode starts flashing light on
  # every load. The nonce is what keeps it alive, so header and markup have to
  # agree — asserting either one alone would pass while the page was broken.
  test "the inline anti-FOUC script carries the nonce the header announces" do
    get new_session_path

    nonce = response.headers["Content-Security-Policy"][/'nonce-([^']+)'/, 1]
    assert nonce.present?, "script-src announces no nonce"
    assert_includes response.body, %(<script nonce="#{nonce}">)
    assert_includes response.body, %(<meta name="csp-nonce" content="#{nonce}")
  end

  test "the nonce is fresh per response rather than derived from the session" do
    get new_session_path
    first = response.headers["Content-Security-Policy"][/'nonce-([^']+)'/, 1]
    get new_session_path
    second = response.headers["Content-Security-Policy"][/'nonce-([^']+)'/, 1]

    assert_not_equal first, second
  end

  # A visitor with no session at all is the case Rails' suggested
  # `session.id` nonce generator gets wrong: it yields "" there, the script
  # gets blocked, and the flash is back for exactly the first-time visitors
  # who notice it most.
  test "a first-time visitor with no session still gets a usable nonce" do
    reset!
    get new_session_path

    nonce = response.headers["Content-Security-Policy"][/'nonce-([^']+)'/, 1]
    assert nonce.present?
    assert_includes response.body, %(<script nonce="#{nonce}">)
  end

  # layouts/minimal has its own copy of the anti-FOUC script, so it needs its
  # own nonce and its own assertion.
  test "the minimal layout gets the nonce too" do
    sign_in_as(users(:one))
    get cook_recipe_path(recipes(:alpha_pancakes))

    nonce = response.headers["Content-Security-Policy"][/'nonce-([^']+)'/, 1]
    assert_includes response.body, %(<script nonce="#{nonce}">)
  end
end
