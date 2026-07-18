class ShoppingListItem < ApplicationRecord
  # Declared in physical store-aisle order (produce first, frozen before
  # pantry, etc.) — `ordered` sorts by this order, not by the `rayon`
  # column's alphabetical text value, so the walk through the store stays
  # coherent instead of "autre" landing before "boissons".
  RAYONS = %w[fruits_legumes frais surgeles epicerie boissons hygiene maison autre].freeze
  RAYON_ORDER_SQL = "CASE rayon #{RAYONS.each_with_index.map { |r, i| "WHEN '#{r}' THEN #{i}" }.join(' ')} ELSE #{RAYONS.size} END"

  belongs_to :shopping_list
  belongs_to :product, optional: true
  belongs_to :recipe, optional: true

  validates :name, presence: true
  validates :rayon, inclusion: { in: RAYONS }, allow_nil: true

  # Unchecked first, then grouped by aisle (in store order), then manual order.
  scope :ordered, -> { order(:checked).order(Arel.sql(RAYON_ORDER_SQL)).order(:position, :id) }

  # Real-time: any creation/update/deletion is broadcast to connected household
  # members subscribed to the list's stream (Solid Cable). Cf. Spec §6.
  broadcasts_to ->(item) { item.shopping_list }
end
