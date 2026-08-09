require "test_helper"

class ShoppingListItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:one))
    @list = shopping_lists(:alpha_groceries)
  end

  test "create adds an item and catalogues the product" do
    assert_difference -> { @list.items.count }, 1 do
      assert_difference -> { households(:alpha).products.count }, 1 do
        post shopping_list_items_path(@list),
          params: { shopping_list_item: { name: "Beurre", rayon: "frais" } }, as: :turbo_stream
      end
    end
    assert_response :success
  end

  test "create with a blank name redirects with an alert" do
    assert_no_difference -> { @list.items.count } do
      post shopping_list_items_path(@list),
        params: { shopping_list_item: { name: "" } }, as: :turbo_stream
    end
    assert_redirected_to @list
  end

  test "toggle flips the checked state" do
    item = shopping_list_items(:alpha_apples)
    patch toggle_shopping_list_item_path(@list, item), as: :turbo_stream
    assert_response :success
    assert item.reload.checked
  end

  test "destroy removes the item" do
    item = shopping_list_items(:alpha_apples)
    delete shopping_list_item_path(@list, item), as: :turbo_stream
    assert_response :success
    assert_not ShoppingListItem.exists?(item.id)
  end

  # Removing a row on its own leaves its aisle band standing over nothing, and
  # the container never becomes empty, so the empty state never appears.
  test "destroying the last item takes its aisle band with it and shows the empty state" do
    list = households(:alpha).shopping_lists.create!(name: "Un seul")
    item = list.items.create!(name: "Pain", rayon: "epicerie")

    delete shopping_list_item_path(list, item), as: :turbo_stream

    assert_turbo_stream action: "update", target: "shopping_list_items"
    assert_not_includes @response.body, I18n.t("shopping_list_items.rayons.epicerie")
    assert_includes @response.body, I18n.t("shopping_lists.show.no_items")
  end

  test "cannot add an item to another household's list" do
    assert_no_difference -> { ShoppingListItem.count } do
      post shopping_list_items_path(shopping_lists(:beta_groceries)),
        params: { shopping_list_item: { name: "Intrus" } }
    end
    assert_response :not_found
  end

  test "move_to_fridge stores the item in the fridge and removes it from the list" do
    item = shopping_list_items(:alpha_apples)
    assert_difference -> { households(:alpha).fridge_items.count }, 1 do
      assert_difference -> { ShoppingListItem.count }, -1 do
        post move_to_fridge_shopping_list_item_path(@list, item), as: :turbo_stream
      end
    end
    assert_response :success
  end

  # The row just disappears otherwise, which looks the same as deleting it.
  test "move_to_fridge raises a toast naming the item" do
    item = shopping_list_items(:alpha_apples)
    post move_to_fridge_shopping_list_item_path(@list, item), as: :turbo_stream

    assert_response :success
    assert_turbo_stream action: "append", target: "flash_relay"
    assert_body_includes I18n.t("shopping_list_items.move_to_fridge.notice", name: item.name)
  end

  test "move_to_fridge captures an expiration date when given" do
    item = shopping_list_items(:alpha_apples)
    post move_to_fridge_shopping_list_item_path(@list, item), params: { expires_on: "2026-08-01" }
    fridge_item = households(:alpha).fridge_items.order(:created_at).last
    assert_equal Date.new(2026, 8, 1), fridge_item.expires_on
  end

  test "move_up swaps position with the previous item in the same rayon" do
    first = shopping_list_items(:alpha_apples) # fruits_legumes, position 0
    second = @list.items.create!(name: "Poires", rayon: "fruits_legumes", position: 1)

    patch move_up_shopping_list_item_path(@list, second)

    assert_equal 0, second.reload.position
    assert_equal 1, first.reload.position
  end

  test "move_up does nothing for the first item in its section" do
    first = shopping_list_items(:alpha_apples)
    patch move_up_shopping_list_item_path(@list, first)
    assert_equal 0, first.reload.position
  end

  test "move_down swaps position with the next item in the same rayon" do
    first = shopping_list_items(:alpha_apples) # fruits_legumes, position 0
    second = @list.items.create!(name: "Poires", rayon: "fruits_legumes", position: 1)

    patch move_down_shopping_list_item_path(@list, first)

    assert_equal 1, first.reload.position
    assert_equal 0, second.reload.position
  end

  test "clear_checked removes every checked item but leaves unchecked ones" do
    checked = shopping_list_items(:alpha_bread) # checked: true
    unchecked = shopping_list_items(:alpha_apples) # checked: false

    delete clear_checked_shopping_list_items_path(@list)

    assert_not ShoppingListItem.exists?(checked.id)
    assert ShoppingListItem.exists?(unchecked.id)
  end
end
