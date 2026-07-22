class PreparedDish < ApplicationRecord
  include HouseholdScoped
  include Perishable

  has_one_attached :photo

  validates :name, presence: true
  validates :location, inclusion: { in: FridgeItem::LOCATIONS }

  scope :ordered, -> { order(:expires_on, :name) }

  # `expires_on` is entered manually; automatic calculation from
  # the ingredients falls under Hest.AI.
  broadcasts_to ->(dish) { dish.household }
end
