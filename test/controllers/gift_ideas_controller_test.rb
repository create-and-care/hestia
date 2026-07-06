require "test_helper"

class GiftIdeasControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    list = gift_lists(:alpha_wishlist)
    post gift_list_gift_ideas_path(list), params: { gift_idea: { name: "Écharpe", price: 15 } }
    assert_redirected_to new_session_path
  end

  test "create adds an idea to the list" do
    list = gift_lists(:alpha_wishlist)
    assert_difference -> { list.gift_ideas.count }, 1 do
      post gift_list_gift_ideas_path(list), params: { gift_idea: { name: "Écharpe", price: 15 } }
    end
    assert_redirected_to list
  end

  test "update changes the idea's status" do
    list = gift_lists(:alpha_wishlist)
    idea = gift_ideas(:alpha_book)
    patch gift_list_gift_idea_path(list, idea), params: { gift_idea: { status: "bought" } }
    assert_redirected_to list
    assert_equal "bought", idea.reload.status
  end

  test "destroy" do
    list = gift_lists(:alpha_wishlist)
    idea = gift_ideas(:alpha_book)
    assert_difference -> { list.gift_ideas.count }, -1 do
      delete gift_list_gift_idea_path(list, idea)
    end
    assert_redirected_to list
  end

  test "cannot add an idea to another household's list" do
    assert_no_difference -> { GiftIdea.count } do
      post gift_list_gift_ideas_path(gift_lists(:beta_list)), params: { gift_idea: { name: "Hack", price: 1 } }
    end
    assert_response :not_found
  end

  test "cannot update an idea belonging to another household's list" do
    patch gift_list_gift_idea_path(gift_lists(:alpha_wishlist), gift_ideas(:beta_gift)), params: { gift_idea: { status: "bought" } }
    assert_response :not_found
  end

  test "cannot destroy an idea belonging to another household's list" do
    delete gift_list_gift_idea_path(gift_lists(:alpha_wishlist), gift_ideas(:beta_gift))
    assert_response :not_found
  end
end
