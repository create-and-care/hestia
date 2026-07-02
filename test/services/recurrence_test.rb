require "test_helper"

class RecurrenceTest < ActiveSupport::TestCase
  test "advances by the frequency and interval" do
    date = Date.new(2026, 1, 10)
    assert_equal Date.new(2026, 1, 13), Recurrence.advance(date, "daily", 3)
    assert_equal Date.new(2026, 1, 24), Recurrence.advance(date, "weekly", 2)
    assert_equal Date.new(2026, 3, 10), Recurrence.advance(date, "monthly", 2)
    assert_equal Date.new(2027, 1, 10), Recurrence.advance(date, "yearly", 1)
  end

  test "treats an interval below 1 as 1" do
    assert_equal Date.new(2026, 1, 11), Recurrence.advance(Date.new(2026, 1, 10), "daily", 0)
  end
end
