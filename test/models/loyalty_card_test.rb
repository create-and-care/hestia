require "test_helper"

class LoyaltyCardTest < ActiveSupport::TestCase
  test "requires a name, a number and a valid format" do
    card = households(:alpha).loyalty_cards.build
    assert_not card.valid?

    card.assign_attributes(name: "X", number: "123", code_format: "barcode")
    assert card.valid?

    card.code_format = "nfc"
    assert_not card.valid?
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).loyalty_cards, loyalty_cards(:beta_card)
  end

  test "rejects an address from another household" do
    card = households(:alpha).loyalty_cards.build(name: "X", number: "1", code_format: "barcode", address: addresses(:beta_place))
    assert_not card.valid?
    assert_includes card.errors[:address], "is invalid"
  end

  test "accepts an address from the same household" do
    card = households(:alpha).loyalty_cards.build(name: "X", number: "1", code_format: "barcode", address: addresses(:alpha_resto))
    assert card.valid?
  end
end
