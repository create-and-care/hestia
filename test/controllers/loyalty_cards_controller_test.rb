require "test_helper"

class LoyaltyCardsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get loyalty_cards_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's cards only" do
    get loyalty_cards_path
    assert_response :success
    assert_includes @response.body, "Supermarché"
    assert_not_includes @response.body, "Carte Beta"
  end

  test "show displays the number" do
    get loyalty_card_path(loyalty_cards(:alpha_supermarket))
    assert_response :success
    assert_includes @response.body, "9876543210123"
  end

  test "create" do
    assert_difference -> { households(:alpha).loyalty_cards.count }, 1 do
      post loyalty_cards_path, params: { loyalty_card: { name: "Librairie", number: "42", code_format: "qrcode" } }
    end
    assert_redirected_to loyalty_cards_path
  end

  test "destroy" do
    card = loyalty_cards(:alpha_supermarket)
    delete loyalty_card_path(card)
    assert_redirected_to loyalty_cards_path
    assert_not LoyaltyCard.exists?(card.id)
  end

  test "cannot access another household's card" do
    get loyalty_card_path(loyalty_cards(:beta_card))
    assert_response :not_found
  end
end
