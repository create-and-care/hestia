require "test_helper"

class GiftListsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get gift_lists_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's lists only" do
    get gift_lists_path
    assert_response :success
    assert_includes @response.body, "Ma liste de Noël"
    assert_not_includes @response.body, "Liste Beta"
  end

  test "create a list" do
    assert_difference -> { households(:alpha).gift_lists.count }, 1 do
      post gift_lists_path, params: { gift_list: { name: "Anniversaire", perspective: "receive" } }
    end
    assert_redirected_to GiftList.find_by(name: "Anniversaire")
  end

  test "add an idea" do
    list = gift_lists(:alpha_wishlist)
    assert_difference -> { list.gift_ideas.count }, 1 do
      post gift_list_gift_ideas_path(list), params: { gift_idea: { name: "Écharpe", price: 15 } }
    end
    assert_redirected_to list
  end

  test "enable a public share link" do
    list = gift_lists(:beta_list) # no share yet — but scoped to alpha; use an alpha list without share
    list = households(:alpha).gift_lists.create!(name: "Sans partage", perspective: "receive")
    assert_difference -> { GiftListShare.count }, 1 do
      post gift_list_share_path(list)
    end
    assert list.reload.shared?
  end

  test "cannot access another household's list" do
    get gift_list_path(gift_lists(:beta_list))
    assert_response :not_found
  end
end
