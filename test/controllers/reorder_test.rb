require "test_helper"

class ReorderTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "reorder shopping list items" do
    list = shopping_lists(:alpha_groceries)
    a = shopping_list_items(:alpha_apples)
    b = shopping_list_items(:alpha_bread)
    patch reorder_shopping_list_items_path(list), params: { ids: [ b.id, a.id ] }, as: :json
    assert_response :no_content
    assert_equal 0, b.reload.position
    assert_equal 1, a.reload.position
  end

  # Via the board: a task's position ranks it inside its own category's column,
  # so that is the only view allowed to write one — see Tasks::ManualOrder.
  test "reorder tasks" do
    get tasks_path(view: "board")
    a = tasks(:alpha_dishes)
    b = tasks(:alpha_call)
    patch reorder_tasks_path, params: { ids: [ b.id, a.id ] }, as: :json
    assert_response :no_content
    assert_equal 0, b.reload.position
    assert_equal 1, a.reload.position
  end

  test "reorder loyalty cards" do
    card = loyalty_cards(:alpha_supermarket)
    other = households(:alpha).loyalty_cards.create!(name: "X", number: "1", code_format: "barcode", position: 1)
    patch reorder_loyalty_cards_path, params: { ids: [ other.id, card.id ] }, as: :json
    assert_response :no_content
    assert_equal 0, other.reload.position
    assert_equal 1, card.reload.position
  end

  test "reorder ignores records from another household" do
    get tasks_path(view: "board")
    beta = tasks(:beta_report)
    original = beta.position
    patch reorder_tasks_path, params: { ids: [ beta.id ] }, as: :json
    assert_response :no_content
    assert_equal original, beta.reload.position
  end
end
