class Bottle < ApplicationRecord
  include HouseholdScoped

  WINE_TYPES = %w[rouge blanc rose petillant autre].freeze

  belongs_to :wine_cellar

  validates :name, presence: true

  scope :in_stock, -> { where(in_stock: true) }
  scope :ordered, -> { order(:name) }

  broadcasts_refreshes_to ->(bottle) { [ bottle.household, "cave" ] }
end
