class WasteCollectionEvent < ApplicationRecord
  include HouseholdScoped

  belongs_to :waste_collection_series, optional: true

  validates :waste_type, inclusion: { in: WasteCollectionSeries::TYPES }
  validates :collected_on, presence: true

  scope :ordered, -> { order(:collected_on) }

  broadcasts_refreshes_to ->(event) { [ event.household, "waste" ] }
end
