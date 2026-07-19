class WasteCollectionSeries < ApplicationRecord
  include HouseholdScoped

  TYPES = %w[ordures recyclage verre compost encombrants].freeze

  has_many :waste_collection_events, dependent: :destroy

  validates :waste_type, inclusion: { in: TYPES }
  validates :weekday, inclusion: { in: 0..6 }
  validates :starts_on, :ends_on, presence: true
  validate :ends_on_after_starts_on

  broadcasts_refreshes_to ->(series) { [ series.household, "waste" ] }

  private
    # Without this, an end date before the start date silently generated zero events while
    # still showing the "series created" success message (Waste::GenerateSeries#generate_events
    # never enters its while loop).
    def ends_on_after_starts_on
      return if starts_on.blank? || ends_on.blank? || ends_on >= starts_on

      errors.add(:ends_on, :before_starts_on)
    end
end
