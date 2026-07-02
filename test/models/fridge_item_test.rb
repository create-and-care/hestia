require "test_helper"

class FridgeItemTest < ActiveSupport::TestCase
  test "requires a name and a valid location" do
    item = households(:alpha).fridge_items.build(location: "refrigerateur")
    assert_not item.valid?

    item.name = "Beurre"
    assert item.valid?

    item.location = "placard"
    assert_not item.valid?
  end

  test "expiration_status is computed from the current date" do
    item = FridgeItem.new
    assert_equal :none, item.expiration_status

    item.expires_on = Date.current - 1
    assert_equal :expired, item.expiration_status

    item.expires_on = Date.current
    assert_equal :urgent, item.expiration_status

    item.expires_on = Date.current + 1
    assert_equal :urgent, item.expiration_status

    item.expires_on = Date.current + 3
    assert_equal :soon, item.expiration_status

    item.expires_on = Date.current + 10
    assert_equal :ok, item.expiration_status
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).fridge_items, fridge_items(:beta_milk)
  end
end
