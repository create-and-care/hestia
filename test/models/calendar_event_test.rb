require "test_helper"

class CalendarEventTest < ActiveSupport::TestCase
  test "requires a title and a start" do
    event = households(:alpha).calendar_events.build(frequency: "none", color: "blue")
    assert_not event.valid?
    event.title = "X"
    event.starts_at = Time.current
    assert event.valid?
  end

  test "a non-recurring event occurs once, only within range" do
    start = Time.zone.local(2026, 7, 15, 10)
    event = CalendarEvent.new(title: "X", starts_at: start, frequency: "none")
    assert_equal [ start ], event.occurrences_between(Time.zone.local(2026, 7, 1), Time.zone.local(2026, 7, 31))
    assert_empty event.occurrences_between(Time.zone.local(2026, 8, 1), Time.zone.local(2026, 8, 31))
  end

  test "weekly recurrence expands within the range" do
    start = Time.zone.local(2026, 7, 1, 9)
    event = CalendarEvent.new(title: "X", starts_at: start, frequency: "weekly", recurrence_interval: 1)
    occurrences = event.occurrences_between(Time.zone.local(2026, 7, 1), Time.zone.local(2026, 7, 31, 23, 59))
    assert_equal 5, occurrences.size # Jul 1, 8, 15, 22, 29
    assert_equal start, occurrences.first
  end

  test "weekly recurrence honours the interval" do
    start = Time.zone.local(2026, 7, 1, 9)
    event = CalendarEvent.new(title: "X", starts_at: start, frequency: "weekly", recurrence_interval: 2)
    occurrences = event.occurrences_between(Time.zone.local(2026, 7, 1), Time.zone.local(2026, 7, 31, 23, 59))
    assert_equal 3, occurrences.size # Jul 1, 15, 29
  end

  test "monthly recurrence expands within the range" do
    start = Time.zone.local(2026, 1, 10, 9)
    event = CalendarEvent.new(title: "X", starts_at: start, frequency: "monthly", recurrence_interval: 1)
    occurrences = event.occurrences_between(Time.zone.local(2026, 1, 1), Time.zone.local(2026, 3, 31, 23, 59))
    assert_equal 3, occurrences.size # Jan 10, Feb 10, Mar 10
  end

  test "recurrence stops at recurrence_until" do
    start = Time.zone.local(2026, 7, 1, 9)
    event = CalendarEvent.new(title: "X", starts_at: start, frequency: "weekly",
      recurrence_interval: 1, recurrence_until: Date.new(2026, 7, 15))
    occurrences = event.occurrences_between(Time.zone.local(2026, 7, 1), Time.zone.local(2026, 7, 31, 23, 59))
    assert_equal 3, occurrences.size # Jul 1, 8, 15
  end

  # ── Bounded loading (PERF-05) ────────────────────────────────────────────
  # The dashboard and the calendar ask for a window; `overlapping` is what
  # keeps the rows that cannot answer out of memory before anything is
  # expanded. Without it, a household's whole calendar history was loaded and
  # unrolled on every dashboard render.
  test "only the events that can reach the window are loaded" do
    household = households(:alpha)
    household.calendar_events.destroy_all
    from = Time.zone.local(2026, 7, 1)
    to = Time.zone.local(2026, 7, 7, 23, 59)

    500.times do |index|
      # A long-finished weekly series: recurring, but its recurrence_until is
      # years before the window.
      household.calendar_events.create!(title: "Ancien #{index}", starts_at: Time.zone.local(2020, 1, 6, 9),
        frequency: "weekly", recurrence_interval: 1, recurrence_until: Date.new(2021, 1, 1))
    end
    live = household.calendar_events.create!(title: "En cours", starts_at: Time.zone.local(2020, 1, 6, 9),
      frequency: "weekly", recurrence_interval: 1)
    future = household.calendar_events.create!(title: "Plus tard", starts_at: Time.zone.local(2027, 1, 6, 9), frequency: "none")

    loaded = household.calendar_events.overlapping(from, to).to_a

    assert_equal [ live ], loaded
    assert_not_includes loaded, future
  end

  test "a one-off inside the window is kept and one outside it is not" do
    household = households(:alpha)
    household.calendar_events.destroy_all
    inside = household.calendar_events.create!(title: "Dedans", starts_at: Time.zone.local(2026, 7, 3, 9), frequency: "none")
    household.calendar_events.create!(title: "Avant", starts_at: Time.zone.local(2026, 6, 3, 9), frequency: "none")

    loaded = household.calendar_events.overlapping(Time.zone.local(2026, 7, 1), Time.zone.local(2026, 7, 7, 23, 59))

    assert_equal [ inside ], loaded.to_a
  end

  test "an endless series older than the previous 1 000-iteration guard still expands" do
    event = CalendarEvent.new(title: "Poubelles", starts_at: Time.zone.local(2000, 1, 5, 8),
      frequency: "weekly", recurrence_interval: 1)

    occurrences = event.occurrences_between(Time.zone.local(2026, 7, 1), Time.zone.local(2026, 7, 15, 23, 59))

    assert_equal 3, occurrences.size
    assert_equal Time.zone.local(2026, 7, 1, 8), occurrences.first
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).calendar_events, calendar_events(:beta_event)
  end

  test "excluded_occurrences skips that date without affecting the rest of the series" do
    start = Time.zone.local(2026, 7, 1, 9)
    event = CalendarEvent.new(title: "X", starts_at: start, frequency: "weekly", recurrence_interval: 1,
      excluded_occurrences: [ Date.new(2026, 7, 15) ])
    occurrences = event.occurrences_between(Time.zone.local(2026, 7, 1), Time.zone.local(2026, 7, 31, 23, 59))
    assert_equal [ Time.zone.local(2026, 7, 1, 9), Time.zone.local(2026, 7, 8, 9), Time.zone.local(2026, 7, 22, 9), Time.zone.local(2026, 7, 29, 9) ], occurrences
  end

  test "rejects an address from another household" do
    event = households(:alpha).calendar_events.build(title: "X", starts_at: Time.current, frequency: "none", address: addresses(:beta_place))
    assert_not event.valid?
    assert_includes event.errors[:address], error_message(:invalid)
  end

  test "accepts an address from the same household" do
    event = households(:alpha).calendar_events.build(title: "X", starts_at: Time.current, frequency: "none", address: addresses(:alpha_resto))
    assert event.valid?
  end
end
