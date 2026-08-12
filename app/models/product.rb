class Product < ApplicationRecord
  include HouseholdScoped

  has_many :shopping_list_items, dependent: :nullify

  validates :name, presence: true
  validates :name, uniqueness: { scope: :household_id, case_sensitive: false }

  # Returns the catalog product with this name (case-insensitive), creating
  # it if needed. Entry point shared by Shopping and Fridge.
  def self.catalog_for(household:, name:, rayon: nil)
    scope = household.products
    scope.where("LOWER(name) = ?", name.to_s.downcase).first ||
      scope.create!(name: name, rayon: rayon)
  end

  # The first catalog product whose name appears anywhere inside the given
  # text — the reverse of catalog_for's exact match, used to recognize a
  # known product inside a longer free-text phrase (Quick Capture) rather
  # than resolve one from an already-isolated name.
  def self.matching(household:, text:)
    return if text.blank?

    household.products.find do |product|
      text.downcase.include?(product.name.downcase)
    end
  end
end
