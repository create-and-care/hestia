module Waste
  # Generates a recurring series of collections (weekday + frequency in weeks
  # + period) in a single action. Service invocable by the web and Hest.AI.
  class GenerateSeries
    def self.call(household:, waste_type:, weekday:, starts_on:, ends_on:, interval_weeks: 1)
      series = household.waste_collection_series.create!(
        waste_type: waste_type, weekday: weekday.to_i,
        interval_weeks: [ interval_weeks.to_i, 1 ].max,
        starts_on: starts_on, ends_on: ends_on
      )
      generate_events(household, series)
      series
    end

    def self.generate_events(household, series)
      date = first_occurrence(series.starts_on, series.weekday)
      step = series.interval_weeks * 7

      while date <= series.ends_on
        household.waste_collection_events.create!(
          waste_collection_series: series, waste_type: series.waste_type, collected_on: date
        )
        date += step
      end
    end

    def self.first_occurrence(from, weekday)
      from + ((weekday - from.wday) % 7)
    end
  end
end
