class ShoppingList < ApplicationRecord
  include HouseholdScoped

  belongs_to :trip, optional: true
  has_many :items, -> { ordered }, class_name: "ShoppingListItem", dependent: :destroy

  validates :name, presence: true

  scope :general, -> { where(trip_id: nil) }
end
