class FridgeItem < ApplicationRecord
  include HouseholdScoped
  include Perishable

  LOCATIONS = %w[refrigerateur congelateur garde_manger].freeze

  belongs_to :product, optional: true

  validates :name, presence: true
  validates :location, inclusion: { in: LOCATIONS }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :ordered, -> { order(:location, :expires_on, :name) }

  # Real-time: broadcast to connected household members (Solid Cable).
  broadcasts_to ->(item) { item.household }
end
