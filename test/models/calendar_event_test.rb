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
    assert_equal 5, occurrences.size # 1, 8, 15, 22, 29 juillet
    assert_equal start, occurrences.first
  end

  test "weekly recurrence honours the interval" do
    start = Time.zone.local(2026, 7, 1, 9)
    event = CalendarEvent.new(title: "X", starts_at: start, frequency: "weekly", recurrence_interval: 2)
    occurrences = event.occurrences_between(Time.zone.local(2026, 7, 1), Time.zone.local(2026, 7, 31, 23, 59))
    assert_equal 3, occurrences.size # 1, 15, 29 juillet
  end

  test "monthly recurrence expands within the range" do
    start = Time.zone.local(2026, 1, 10, 9)
    event = CalendarEvent.new(title: "X", starts_at: start, frequency: "monthly", recurrence_interval: 1)
    occurrences = event.occurrences_between(Time.zone.local(2026, 1, 1), Time.zone.local(2026, 3, 31, 23, 59))
    assert_equal 3, occurrences.size # 10 jan, fév, mars
  end

  test "recurrence stops at recurrence_until" do
    start = Time.zone.local(2026, 7, 1, 9)
    event = CalendarEvent.new(title: "X", starts_at: start, frequency: "weekly",
      recurrence_interval: 1, recurrence_until: Date.new(2026, 7, 15))
    occurrences = event.occurrences_between(Time.zone.local(2026, 7, 1), Time.zone.local(2026, 7, 31, 23, 59))
    assert_equal 3, occurrences.size # 1, 8, 15 juillet
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).calendar_events, calendar_events(:beta_event)
  end
end
