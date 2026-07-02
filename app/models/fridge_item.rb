class FridgeItem < ApplicationRecord
  include HouseholdScoped
  include Perishable

  LOCATIONS = %w[refrigerateur congelateur garde_manger].freeze

  belongs_to :product, optional: true

  validates :name, presence: true
  validates :location, inclusion: { in: LOCATIONS }

  scope :ordered, -> { order(:location, :expires_on, :name) }

  # Temps réel : diffusé aux membres du foyer connectés (Solid Cable) — CDC §6.
  broadcasts_to ->(item) { item.household }
end
