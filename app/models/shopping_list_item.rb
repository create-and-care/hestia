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

  # Real-time to connected household members (Solid Cable). An edit replaces its
  # own row, but a creation or a deletion changes the *shape* of the list, and a
  # single row cannot carry that: the rayon bands are rendered from the items, so
  # an appended row lands underneath every band instead of inside its own, and a
  # removed one leaves its band standing over nothing once it was the last of its
  # aisle — with the container never actually becoming empty, so the empty state
  # stays hidden. Both re-render the container instead, which is what
  # ShoppingListItemsController#respond_with_list already does for the actions
  # that reorder or bulk-clear.
  after_create_commit -> { broadcast_list_later }
  after_update_commit -> { broadcast_replace_later_to shopping_list }
  after_destroy_commit -> { broadcast_list }

  private
    def broadcast_list_later
      broadcast_update_later_to shopping_list, **list_rendering
    end

    # Synchronous on the destroy path, where the deferred version cannot work:
    # Turbo always folds the record itself into the locals, and by the time the
    # job runs there is no row left to load it from — so it raises a
    # DeserializationError, which Turbo::Streams::ActionBroadcastJob discards.
    # The broadcast simply never arrives, without an error anywhere.
    def broadcast_list
      broadcast_update_to shopping_list, **list_rendering
    end

    def list_rendering
      { target: "shopping_list_items", partial: "shopping_list_items/list",
        locals: { shopping_list: shopping_list } }
    end
end
