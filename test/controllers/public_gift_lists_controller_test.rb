require "test_helper"

class PublicGiftListsControllerTest < ActionDispatch::IntegrationTest
  # These tests verify the NON-authenticated public access (architecture deviation, Spec §5).

  test "shows a shared list without any authentication" do
    get public_gift_list_path(gift_list_shares(:alpha_share).token)
    assert_response :success
    assert_includes @response.body, "Livre de cuisine"
  end

  test "reserve an idea without an account" do
    idea = gift_ideas(:alpha_book)
    assert_difference -> { idea.gift_reservations.count }, 1 do
      post reserve_public_gift_path(gift_list_shares(:alpha_share).token, idea), params: { reserver_name: "Tante Jeanne" }
    end
    assert_redirected_to public_gift_list_path(gift_list_shares(:alpha_share).token)
  end

  test "the reserving browser can cancel its own reservation" do
    idea = gift_ideas(:alpha_book)
    post reserve_public_gift_path(gift_list_shares(:alpha_share).token, idea), params: { reserver_name: "X" }

    delete unreserve_public_gift_path(gift_list_shares(:alpha_share).token, idea)
    assert_equal 0, idea.gift_reservations.count
  end

  test "a different browser cannot cancel someone else's reservation" do
    idea = gift_ideas(:alpha_book)
    idea.gift_reservations.create!(reserver_name: "X") # no reservation cookie set for this session

    delete unreserve_public_gift_path(gift_list_shares(:alpha_share).token, idea)
    assert_equal 1, idea.gift_reservations.count
  end

  test "an unknown token returns not found" do
    get public_gift_list_path("does-not-exist")
    assert_response :not_found
  end
end
