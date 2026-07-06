require "test_helper"

class GiftListSharesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    list = households(:alpha).gift_lists.create!(name: "Sans partage", perspective: "receive")
    post gift_list_share_path(list)
    assert_redirected_to new_session_path
  end

  test "create enables a share for a list without one" do
    list = households(:alpha).gift_lists.create!(name: "Sans partage", perspective: "receive")
    assert_difference -> { GiftListShare.count }, 1 do
      post gift_list_share_path(list)
    end
    assert_redirected_to list
    assert list.reload.shared?
  end

  test "create is idempotent when the list is already shared" do
    list = gift_lists(:alpha_wishlist)
    assert list.gift_list_share.present?
    assert_no_difference -> { GiftListShare.count } do
      post gift_list_share_path(list)
    end
    assert_redirected_to list
  end

  test "destroy disables the share" do
    list = gift_lists(:alpha_wishlist)
    assert_difference -> { GiftListShare.count }, -1 do
      delete gift_list_share_path(list)
    end
    assert_redirected_to list
    assert_not list.reload.shared?
  end

  test "destroy without an existing share does not raise" do
    list = households(:alpha).gift_lists.create!(name: "Sans partage", perspective: "receive")
    delete gift_list_share_path(list)
    assert_redirected_to list
  end

  test "cannot create a share for another household's list" do
    assert_no_difference -> { GiftListShare.count } do
      post gift_list_share_path(gift_lists(:beta_list))
    end
    assert_response :not_found
  end

  test "cannot destroy another household's share" do
    delete gift_list_share_path(gift_lists(:beta_list))
    assert_response :not_found
  end
end
