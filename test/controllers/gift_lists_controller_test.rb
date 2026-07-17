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

  test "create ignores contact_id for a receive list" do
    post gift_lists_path, params: { gift_list: { name: "Souhaits", perspective: "receive", contact_id: contacts(:alpha_mom).id } }
    assert_nil GiftList.find_by!(name: "Souhaits").contact_id
  end

  test "the creator can rename their list" do
    list = gift_lists(:alpha_wishlist)
    list.update!(created_by: users(:one))
    patch gift_list_path(list), params: { gift_list: { name: "Nouveau nom", perspective: "receive" } }
    assert_equal "Nouveau nom", list.reload.name
  end

  test "a non-creator household member cannot edit the list" do
    other = User.create!(name: "Autre", email_address: "autre@example.com", password: "password")
    households(:alpha).memberships.create!(user: other, role: "member")

    list = gift_lists(:alpha_wishlist)
    list.update!(created_by: users(:one))

    sign_in_as(other)
    patch gift_list_path(list), params: { gift_list: { name: "Piraté", perspective: "receive" } }
    assert_not_equal "Piraté", list.reload.name
  end

  test "a restricted list is hidden from household members who aren't included" do
    other = User.create!(name: "Autre", email_address: "autre@example.com", password: "password")
    households(:alpha).memberships.create!(user: other, role: "member")

    list = gift_lists(:alpha_wishlist)
    list.update!(created_by: users(:one), restricted: true, visible_to_ids: [])

    sign_in_as(other)
    get gift_list_path(list)
    assert_response :not_found
  end

  test "a restricted list stays visible to members explicitly included" do
    other = User.create!(name: "Autre", email_address: "autre@example.com", password: "password")
    households(:alpha).memberships.create!(user: other, role: "member")

    list = gift_lists(:alpha_wishlist)
    list.update!(created_by: users(:one), restricted: true, visible_to_ids: [ other.id ])

    sign_in_as(other)
    get gift_list_path(list)
    assert_response :success
  end

  test "edit renders the settings page" do
    list = gift_lists(:alpha_wishlist)
    list.update!(created_by: users(:one))
    get edit_gift_list_path(list)
    assert_response :success
  end

  test "the creator can never be excluded from their own restricted list" do
    list = gift_lists(:alpha_wishlist)
    list.update!(created_by: users(:one), restricted: true, visible_to_ids: [])
    assert_includes list.reload.visible_to_ids, users(:one).id
  end
end
