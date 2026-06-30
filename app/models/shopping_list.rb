class ShoppingList < ApplicationRecord
  include HouseholdScoped

  has_many :items, -> { ordered }, class_name: "ShoppingListItem", dependent: :destroy

  validates :name, presence: true
end
