require "test_helper"
require "turbo/broadcastable/test_helper"

class ShoppingListItemTest < ActiveSupport::TestCase
  # turbo-rails only auto-includes this under on_load(:action_cable), so whether
  # it is there depends on what else the run happened to load first.
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  test "requires a name" do
    item = shopping_lists(:alpha_groceries).items.build(rayon: "frais")
    assert_not item.valid?
  end

  test "rejects an unknown rayon" do
    item = shopping_lists(:alpha_groceries).items.build(name: "X", rayon: "inconnu")
    assert_not item.valid?
  end

  test "allows a nil rayon" do
    item = shopping_lists(:alpha_groceries).items.build(name: "X", rayon: nil)
    assert item.valid?
  end

  test "orders items by store-aisle order rather than alphabetically" do
    list = shopping_lists(:alpha_groceries)
    drinks = list.items.create!(name: "Eau", rayon: "boissons")
    other = list.items.create!(name: "Divers", rayon: "autre")
    produce = list.items.create!(name: "Tomate", rayon: "fruits_legumes")

    ids_in_order = list.reload.items.map(&:id) & [ produce.id, drinks.id, other.id ]
    assert_equal [ produce.id, drinks.id, other.id ], ids_in_order
  end

  # The other members' half of the same bug the controller covers: a bare append
  # drops the row below every aisle band, and a bare remove leaves an empty band
  # standing with the empty state still hidden behind it.
  test "a creation broadcasts the whole list rather than the single row" do
    list = shopping_lists(:alpha_groceries)

    streams = capture_turbo_stream_broadcasts(list) do
      perform_enqueued_jobs { list.items.create!(name: "Pain", rayon: "epicerie") }
    end

    assert_equal "update", streams.last["action"]
    assert_equal "shopping_list_items", streams.last["target"]
  end

  test "a deletion broadcasts the whole list rather than removing the row" do
    list = shopping_lists(:alpha_groceries)
    item = list.items.create!(name: "Pain", rayon: "epicerie")

    streams = capture_turbo_stream_broadcasts(list) do
      perform_enqueued_jobs { item.destroy }
    end

    assert_equal "update", streams.last["action"]
    assert_equal "shopping_list_items", streams.last["target"]
  end

  test "an edit still replaces just its own row" do
    item = shopping_list_items(:alpha_apples)

    streams = capture_turbo_stream_broadcasts(item.shopping_list) do
      perform_enqueued_jobs { item.update!(name: "Pommes vertes") }
    end

    assert_equal "replace", streams.last["action"]
    assert_equal ActionView::RecordIdentifier.dom_id(item), streams.last["target"]
  end
end
