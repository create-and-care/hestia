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

  test "cannot add an item to another household's list" do
    assert_no_difference -> { ShoppingListItem.count } do
      post shopping_list_items_path(shopping_lists(:beta_groceries)),
        params: { shopping_list_item: { name: "Intrus" } }
    end
    assert_response :not_found
  end
end
