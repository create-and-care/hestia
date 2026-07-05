require "test_helper"

class LoyaltyBrandTest < ActiveSupport::TestCase
  test "requires a unique name" do
    LoyaltyBrand.create!(name: "Carrefour", code_format: "barcode")
    duplicate = LoyaltyBrand.new(name: "Carrefour", code_format: "barcode")
    assert_not duplicate.valid?
  end

  test "loyalty cards remain valid without a catalogue brand" do
    card = LoyaltyCard.new(household: households(:alpha), name: "Enseigne locale", number: "123", code_format: "barcode")
    assert card.valid?
    assert_nil card.loyalty_brand
  end
end
