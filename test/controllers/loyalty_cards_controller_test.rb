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

  test "show renders a real scannable code instead of plain text" do
    get loyalty_card_path(loyalty_cards(:alpha_supermarket))
    assert_response :success
    assert_select "svg"
  end

  test "kiosk renders full-screen without the sidebar" do
    get kiosk_loyalty_card_path(loyalty_cards(:alpha_supermarket))
    assert_response :success
    assert_select "svg"
    assert_select "[data-controller='sidebar']", false
  end

  test "cannot access another household's card in kiosk mode" do
    get kiosk_loyalty_card_path(loyalty_cards(:beta_card))
    assert_response :not_found
  end

  test "move_up and move_down swap position with the adjacent card" do
    supermarket = loyalty_cards(:alpha_supermarket)
    other = households(:alpha).loyalty_cards.create!(name: "Librairie", number: "1", code_format: "barcode", position: 1)

    patch move_down_loyalty_card_path(supermarket)
    assert_equal 1, supermarket.reload.position
    assert_equal 0, other.reload.position

    patch move_up_loyalty_card_path(supermarket)
    assert_equal 0, supermarket.reload.position
    assert_equal 1, other.reload.position
  end

  test "delete uses the design-system alert dialog instead of a native confirm, and edit has an accessible name" do
    card = loyalty_cards(:alpha_supermarket)
    get loyalty_cards_path
    assert_select "dialog[role='alertdialog']"
    assert_select "form[action=?]", loyalty_card_path(card)
    assert_no_match(/data-turbo-confirm="#{Regexp.escape(I18n.t("loyalty_cards.loyalty_card.delete_confirm", name: card.name))}"/, @response.body)
    assert_select "a[href=?][aria-label=?]", edit_loyalty_card_path(card), "Edit \"Supermarché\""
  end

  test "create links an address from the household's address book" do
    post loyalty_cards_path, params: {
      loyalty_card: { name: "Librairie", number: "1", code_format: "barcode", address_id: addresses(:alpha_resto).id }
    }
    assert_equal addresses(:alpha_resto), LoyaltyCard.find_by!(name: "Librairie").address
  end

  test "the card form offers the household's addresses" do
    get new_loyalty_card_path
    assert_select "select#loyalty_card_address_id option", text: addresses(:alpha_resto).name
    assert_select "select#loyalty_card_address_id option", text: addresses(:beta_place).name, count: 0
  end

  test "sortable list is wired with an error message for a failed reorder" do
    get loyalty_cards_path
    assert_select "#loyalty_cards[data-sortable-error-message-value]"
  end
end
