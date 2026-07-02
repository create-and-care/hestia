module Recurrence
  PERIODS = { "daily" => :days, "weekly" => :weeks, "monthly" => :months, "yearly" => :years }.freeze

  # Moteur de récurrence mutualisé entre Calendrier et Routines (CDC §11.2) :
  # avance une date/heure d'un intervalle selon la fréquence.
  def self.advance(moment, frequency, interval = 1)
    step = [ interval.to_i, 1 ].max
    unit = PERIODS.fetch(frequency, :days)
    moment.advance(unit => step)
  end
end
