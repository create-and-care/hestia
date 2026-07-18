require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # CI runners are noticeably slower/noisier than local dev machines, so a
  # sign-out redirect or Turbo navigation that finishes in time locally can
  # still exceed a tight wait window there. 10s gives real requests enough
  # headroom without masking a genuinely broken assertion.
  Capybara.default_max_wait_time = 10
end
