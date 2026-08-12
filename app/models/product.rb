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

  # The most specific catalog product whose name appears anywhere inside the
  # given text — the reverse of catalog_for's exact match, used to recognize a
  # known product inside a longer free-text phrase (Quick Capture) rather
  # than resolve one from an already-isolated name. When several product
  # names match (e.g. "Lait" and "Lait 2%" both appear in "du lait 2%"), the
  # longest name wins as the more specific match.
  def self.matching(household:, text:)
    return if text.blank?

    downcased_text = text.downcase
    household.products
      .select { |product| downcased_text.include?(product.name.downcase) }
      .max_by { |product| product.name.length }
  end
end
