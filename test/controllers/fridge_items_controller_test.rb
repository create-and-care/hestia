require "test_helper"

class FridgeItemsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds an item and catalogues the product" do
    assert_difference -> { households(:alpha).fridge_items.count }, 1 do
      assert_difference -> { households(:alpha).products.count }, 1 do
        post fridge_items_path,
          params: { fridge_item: { name: "Fromage", location: "refrigerateur", expires_on: Date.current + 4 } },
          as: :turbo_stream
      end
    end
    assert_response :success
  end

  test "create with a blank name redirects with an alert" do
    assert_no_difference -> { FridgeItem.count } do
      post fridge_items_path,
        params: { fridge_item: { name: "", location: "refrigerateur" } }, as: :turbo_stream
    end
    assert_redirected_to fridge_path
  end

  test "update changes the location" do
    item = fridge_items(:alpha_yogurt)
    patch fridge_item_path(item), params: { fridge_item: { location: "congelateur" } }
    assert_redirected_to fridge_path
    assert_equal "congelateur", item.reload.location
  end

  test "destroy removes the item" do
    item = fridge_items(:alpha_yogurt)
    delete fridge_item_path(item), as: :turbo_stream
    assert_response :success
    assert_not FridgeItem.exists?(item.id)
  end

  test "move_to_shopping_list adds it to a list" do
    assert_difference -> { ShoppingListItem.count }, 1 do
      post move_to_shopping_list_fridge_item_path(fridge_items(:alpha_yogurt))
    end
    assert_redirected_to fridge_path
  end

  test "cannot touch another household's fridge item" do
    delete fridge_item_path(fridge_items(:beta_milk))
    assert_response :not_found
  end
end
