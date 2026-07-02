class SavingsEnvelope < ApplicationRecord
  include HouseholdScoped

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  broadcasts_refreshes_to ->(envelope) { [ envelope.household, "budget" ] }
end
