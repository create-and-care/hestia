class ShoppingList < ApplicationRecord
  include HouseholdScoped

  belongs_to :trip, optional: true
  has_many :items, -> { ordered }, class_name: "ShoppingListItem", dependent: :destroy
  has_one :conversation, as: :subject, dependent: :nullify

  validates :name, presence: true

  scope :general, -> { where(trip_id: nil) }

  # Groups the (already checked/aisle/position-ordered) items by rayon,
  # preserving the canonical store-aisle order — shared by the on-screen
  # list and the PDF export so both group items identically.
  def items_by_rayon
    grouped = items.group_by { |item| item.rayon || "autre" }
    (ShoppingListItem::RAYONS & grouped.keys).index_with { |rayon| grouped[rayon] }
  end
end
