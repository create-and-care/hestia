class PreparedDish < ApplicationRecord
  include HouseholdScoped
  include Perishable

  validates :name, presence: true
  validates :location, inclusion: { in: FridgeItem::LOCATIONS }

  scope :ordered, -> { order(:expires_on, :name) }

  # In Phase 2, `expires_on` is entered manually; automatic calculation from
  # the ingredients falls under Hest.AI (Phase 3, Spec §9.4).
  broadcasts_to ->(dish) { dish.household }
end
