class Plant < ApplicationRecord
  include HouseholdScoped

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  broadcasts_refreshes_to ->(plant) { [ plant.household, "exterior" ] }
end
