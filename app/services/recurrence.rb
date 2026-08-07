module Recurrence
  PERIODS = { "daily" => :days, "weekly" => :weeks, "monthly" => :months, "yearly" => :years }.freeze

  # Safety net on #occurrences_between. It bounds the *window*, not the age of
  # the series, so it is only ever reached by asking for an absurd range (a
  # daily series over a decade) — never by an old event, which is what the
  # previous 1 000-iteration guard in CalendarEvent silently truncated.
  MAX_OCCURRENCES = 1_000

  # Recurrence engine shared between Calendar and Routines:
  # advances a date/time by an interval according to the frequency.
  def self.advance(moment, frequency, interval = 1)
    step = [ interval.to_i, 1 ].max
    unit = PERIODS.fetch(frequency, :days)
    moment.advance(unit => step)
  end

  # The occurrence `offset` steps after the start of a series.
  #
  # Always measured from `start`, never accumulated: for a monthly series that
  # begins on the 31st, `start.advance(months: 2)` is 31 March, whereas
  # advancing one month twice gives 28 February and then 28 March — the day of
  # month collapses at the first short month and never recovers. Anchoring on
  # the original date is both what calendars do and what makes the jump below
  # sound.
  def self.occurrence(start, frequency, offset)
    return start if offset <= 0

    start.advance(PERIODS.fetch(frequency, :days) => offset)
  end

  # Every occurrence of a series in [from, to], ascending.
  #
  # The cursor jumps straight to the first occurrence at or after `from`
  # instead of walking the series from its beginning. Callers ask for a window
  # — the dashboard wants the next seven days, the calendar one month — and
  # the cost is now proportional to that window rather than to how long ago
  # the series started. A weekly event created three years ago had 150-odd
  # past occurrences to step over, per event, on every page load.
  def self.occurrences_between(start:, from:, to:, frequency:, interval: 1)
    return [] if start.blank? || to < from

    step = [ interval.to_i, 1 ].max
    index = steps_before(start, from, frequency, step)
    occurrences = []

    while occurrences.size < MAX_OCCURRENCES
      moment = occurrence(start, frequency, index * step)
      break if moment > to

      occurrences << moment if moment >= from
      index += 1
    end

    occurrences
  end

  # How many whole steps of the series fit between its start and `from`.
  #
  # Deliberately a floor: landing one step early costs a single discarded
  # iteration, whereas landing one step late would drop a real occurrence.
  # The month arithmetic ignores the day of month for the same reason — the
  # occurrence it may skip is necessarily in a month before `from`'s.
  def self.steps_before(start, from, frequency, step)
    return 0 if from <= start

    elapsed = case PERIODS.fetch(frequency, :days)
    when :days   then (from.to_date - start.to_date).to_i
    when :weeks  then (from.to_date - start.to_date).to_i / 7
    when :months then (from.year * 12 + from.month) - (start.year * 12 + start.month)
    when :years  then from.year - start.year
    end

    [ elapsed / step, 0 ].max
  end
end
