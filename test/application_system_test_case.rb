require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Selenium only looks for Chrome where an installer would have put it, so a
  # machine whose only Chrome is the Chrome for Testing that Puppeteer
  # downloaded for visual:check can't run this suite at all. CHROME_BINARY
  # points at it instead of asking for a second browser to be installed:
  #   CHROME_BINARY="$HOME/.cache/puppeteer/chrome/<version>/chrome-mac-arm64/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"
  Selenium::WebDriver::Chrome.path = ENV["CHROME_BINARY"] if ENV["CHROME_BINARY"].present?

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # CI runners are noticeably slower/noisier than local dev machines, so a
  # sign-out redirect or Turbo navigation that finishes in time locally can
  # still exceed a tight wait window there. 10s gives real requests enough
  # headroom without masking a genuinely broken assertion.
  Capybara.default_max_wait_time = 10
end
