class FridgeItem < ApplicationRecord
  include HouseholdScoped
  include Perishable

  LOCATIONS = %w[refrigerateur congelateur garde_manger].freeze

  belongs_to :product, optional: true

  validates :name, presence: true
  validates :location, inclusion: { in: LOCATIONS }
  # Matches the quantity column's own decimal(10, 2): without this, a value
  # above 99_999_999.99 doesn't fail validation, it raises PG::NumericValueOutOfRange
  # (ActiveRecord::RangeError) straight out of the INSERT/UPDATE.
  validates :quantity, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 99_999_999.99 }, allow_nil: true

  scope :ordered, -> { order(:location, :expires_on, :name) }

  # Real-time: broadcast to connected household members (Solid Cable).
  broadcasts_to ->(item) { item.household }
end
