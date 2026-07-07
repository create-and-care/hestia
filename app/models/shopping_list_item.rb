class ShoppingListItem < ApplicationRecord
  RAYONS = %w[fruits_legumes frais surgeles epicerie boissons hygiene maison autre].freeze

  belongs_to :shopping_list
  belongs_to :product, optional: true
  belongs_to :recipe, optional: true

  validates :name, presence: true
  validates :rayon, inclusion: { in: RAYONS }, allow_nil: true

  # Unchecked first, then grouped by aisle, then manual order.
  scope :ordered, -> { order(:checked, :rayon, :position, :id) }

  # Real-time: any creation/update/deletion is broadcast to connected household
  # members subscribed to the list's stream (Solid Cable). Cf. Spec §6.
  broadcasts_to ->(item) { item.shopping_list }
end
