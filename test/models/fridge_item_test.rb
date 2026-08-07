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

  test "expiring matches exactly the items expiration_status flags, soonest first" do
    household = households(:alpha)
    household.fridge_items.destroy_all
    soon = household.fridge_items.create!(name: "Bientôt", location: "refrigerateur",
      expires_on: Perishable::SOON_DAYS.days.from_now.to_date)
    expired = household.fridge_items.create!(name: "Périmé", location: "refrigerateur", expires_on: 2.days.ago.to_date)
    fresh = household.fridge_items.create!(name: "Frais", location: "refrigerateur", expires_on: 30.days.from_now.to_date)
    household.fridge_items.create!(name: "Sans date", location: "refrigerateur", expires_on: nil)

    assert_equal [ expired, soon ], household.fridge_items.expiring.to_a
    assert_equal :ok, fresh.expiration_status
  end
end
