require "test_helper"

class ShoppingListsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get shopping_lists_path
    assert_redirected_to new_session_path
  end

  test "index shows only the household's lists" do
    get shopping_lists_path
    assert_response :success
    assert_includes @response.body, "Courses Alpha"
    assert_not_includes @response.body, "Courses Beta"
  end

  test "show renders the list and wires the real-time stream" do
    get shopping_list_path(shopping_lists(:alpha_groceries))
    assert_response :success
    assert_select "turbo-cable-stream-source"
    assert_includes @response.body, "Pommes"
  end

  test "create" do
    assert_difference -> { households(:alpha).shopping_lists.count }, 1 do
      post shopping_lists_path, params: { shopping_list: { name: "Drive", icon: "🛒" } }
    end
    assert_redirected_to shopping_list_path(ShoppingList.find_by(name: "Drive"))
  end

  test "destroy" do
    list = shopping_lists(:alpha_groceries)
    delete shopping_list_path(list)
    assert_redirected_to shopping_lists_path
    assert_not ShoppingList.exists?(list.id)
  end

  test "cannot access another household's list" do
    get shopping_list_path(shopping_lists(:beta_groceries))
    assert_response :not_found
  end

  test "show offers a discuss-this-list shortcut into Messages" do
    get shopping_list_path(shopping_lists(:alpha_groceries))
    assert_response :success
    assert_select "form[action^=?]", discuss_conversations_path
  end
end
