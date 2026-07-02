class WasteCollectionSeries < ApplicationRecord
  include HouseholdScoped

  TYPES = %w[ordures recyclage verre compost encombrants].freeze

  has_many :waste_collection_events, dependent: :destroy

  validates :waste_type, inclusion: { in: TYPES }
  validates :weekday, inclusion: { in: 0..6 }
  validates :starts_on, :ends_on, presence: true

  broadcasts_refreshes_to ->(series) { [ series.household, "waste" ] }
end
