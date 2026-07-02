class Product < ApplicationRecord
  include HouseholdScoped

  has_many :shopping_list_items, dependent: :nullify

  validates :name, presence: true
  validates :name, uniqueness: { scope: :household_id, case_sensitive: false }

  # Retourne le produit du catalogue portant ce nom (insensible à la casse), en le
  # créant au besoin. Point d'entrée partagé par Courses et Frigo.
  def self.catalog_for(household:, name:, rayon: nil)
    scope = household.products
    scope.where("LOWER(name) = ?", name.to_s.downcase).first ||
      scope.create!(name: name, rayon: rayon)
  end
end
