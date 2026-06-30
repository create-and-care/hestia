class ShoppingListItem < ApplicationRecord
  RAYONS = %w[fruits_legumes frais surgeles epicerie boissons hygiene maison autre].freeze

  belongs_to :shopping_list
  belongs_to :product, optional: true

  validates :name, presence: true
  validates :rayon, inclusion: { in: RAYONS }, allow_nil: true

  # Non cochés d'abord, puis groupés par rayon, puis ordre manuel.
  scope :ordered, -> { order(:checked, :rayon, :position, :id) }

  # Temps réel : toute création/modification/suppression est diffusée aux membres
  # connectés du foyer abonnés au flux de la liste (Solid Cable). Cf. CDC §6.
  broadcasts_to ->(item) { item.shopping_list }
end
