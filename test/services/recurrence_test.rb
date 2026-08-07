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

  # ── Bounded window (PERF-05) ─────────────────────────────────────────────
  test "expands only the requested window, whatever the age of the series" do
    start = Time.zone.local(2015, 1, 5, 8) # weekly for a decade

    occurrences = Recurrence.occurrences_between(start: start, frequency: "weekly", interval: 1,
      from: Time.zone.local(2026, 7, 1), to: Time.zone.local(2026, 7, 31, 23, 59))

    assert_equal 4, occurrences.size
    assert_equal Time.zone.local(2026, 7, 6, 8), occurrences.first
    assert_equal Time.zone.local(2026, 7, 27, 8), occurrences.last
  end

  # The old expansion gave up after 1 000 steps from the series' first date, so
  # a weekly event more than ~19 years old simply stopped appearing.
  test "a series older than the previous iteration guard still yields its occurrences" do
    start = Time.zone.local(2000, 1, 5, 8) # >1 350 weekly steps ago

    occurrences = Recurrence.occurrences_between(start: start, frequency: "weekly", interval: 1,
      from: Time.zone.local(2026, 7, 1), to: Time.zone.local(2026, 7, 15, 23, 59))

    assert_equal [ Time.zone.local(2026, 7, 1, 8), Time.zone.local(2026, 7, 8, 8), Time.zone.local(2026, 7, 15, 8) ], occurrences
  end

  test "counts steps from the start, so a monthly series keeps its day of month" do
    start = Date.new(2026, 1, 31)

    occurrences = Recurrence.occurrences_between(start: start, frequency: "monthly", interval: 1,
      from: Date.new(2026, 1, 1), to: Date.new(2026, 5, 1))

    # February clamps to the 28th, but March goes back to the 31st rather than
    # dragging the whole series onto the 28th for good.
    assert_equal [ Date.new(2026, 1, 31), Date.new(2026, 2, 28), Date.new(2026, 3, 31), Date.new(2026, 4, 30) ], occurrences
  end

  test "an interval wider than the window can still land inside it" do
    occurrences = Recurrence.occurrences_between(start: Date.new(2026, 1, 1), frequency: "monthly", interval: 6,
      from: Date.new(2026, 7, 1), to: Date.new(2026, 7, 31))

    assert_equal [ Date.new(2026, 7, 1) ], occurrences
  end

  test "returns nothing for an empty or inverted window" do
    assert_empty Recurrence.occurrences_between(start: Date.new(2026, 1, 1), frequency: "daily", interval: 1,
      from: Date.new(2026, 7, 31), to: Date.new(2026, 7, 1))
    assert_empty Recurrence.occurrences_between(start: nil, frequency: "daily", interval: 1,
      from: Date.new(2026, 7, 1), to: Date.new(2026, 7, 31))
  end

  test "a window starting before the series does not invent occurrences before it" do
    occurrences = Recurrence.occurrences_between(start: Date.new(2026, 7, 10), frequency: "weekly", interval: 1,
      from: Date.new(2026, 1, 1), to: Date.new(2026, 7, 31))

    assert_equal [ Date.new(2026, 7, 10), Date.new(2026, 7, 17), Date.new(2026, 7, 24), Date.new(2026, 7, 31) ], occurrences
  end
end
