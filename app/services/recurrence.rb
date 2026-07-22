module Recurrence
  PERIODS = { "daily" => :days, "weekly" => :weeks, "monthly" => :months, "yearly" => :years }.freeze

  # Recurrence engine shared between Calendar and Routines:
  # advances a date/time by an interval according to the frequency.
  def self.advance(moment, frequency, interval = 1)
    step = [ interval.to_i, 1 ].max
    unit = PERIODS.fetch(frequency, :days)
    moment.advance(unit => step)
  end
end
