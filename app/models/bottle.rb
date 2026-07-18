class Bottle < ApplicationRecord
  include HouseholdScoped

  WINE_TYPES = %w[rouge blanc rose petillant autre].freeze

  belongs_to :wine_cellar
  belongs_to :recipe, optional: true
  has_one_attached :photo

  validates :name, presence: true
  validate :wine_cellar_belongs_to_household

  scope :in_stock, -> { where(in_stock: true) }
  scope :ordered, -> { order(:name) }

  broadcasts_refreshes_to ->(bottle) { [ bottle.household, "cave" ] }

  private
    def wine_cellar_belongs_to_household
      errors.add(:wine_cellar, :invalid) if wine_cellar && wine_cellar.household_id != household_id
    end
end
