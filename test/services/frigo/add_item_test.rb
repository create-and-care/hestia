require "test_helper"

module Frigo
  class AddItemTest < ActiveSupport::TestCase
    test "creates a fridge item and catalogues the product" do
      assert_difference -> { households(:alpha).fridge_items.count }, 1 do
        assert_difference -> { households(:alpha).products.count }, 1 do
          Frigo::AddItem.call(household: households(:alpha), name: "Fromage",
            location: "refrigerateur", expires_on: Date.current + 5)
        end
      end
    end

    test "defaults the location to refrigerateur" do
      item = Frigo::AddItem.call(household: households(:alpha), name: "Oeufs")
      assert_equal "refrigerateur", item.location
    end

    test "reuses an existing catalogue product" do
      existing = products(:alpha_milk)
      assert_no_difference -> { households(:alpha).products.count } do
        item = Frigo::AddItem.call(household: households(:alpha), name: "lait")
        assert_equal existing, item.product
      end
    end
  end
end
