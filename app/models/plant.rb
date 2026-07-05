class Plant < ApplicationRecord
  include HouseholdScoped

  belongs_to :plant_reference, optional: true

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  broadcasts_refreshes_to ->(plant) { [ plant.household, "exterior" ] }
end
