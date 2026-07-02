class PreparedDish < ApplicationRecord
  include HouseholdScoped
  include Perishable

  validates :name, presence: true
  validates :location, inclusion: { in: FridgeItem::LOCATIONS }

  scope :ordered, -> { order(:expires_on, :name) }

  # En Phase 2, `expires_on` est saisi manuellement ; le calcul automatique à partir
  # des ingrédients relève de Hest.IA (Phase 3, CDC §9.4).
  broadcasts_to ->(dish) { dish.household }
end
