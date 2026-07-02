require "test_helper"

class PreparedDishTest < ActiveSupport::TestCase
  test "requires a name and a valid location" do
    dish = households(:alpha).prepared_dishes.build(name: "Soupe", location: "refrigerateur")
    assert dish.valid?

    dish.location = "cave"
    assert_not dish.valid?

    dish.location = "refrigerateur"
    dish.name = nil
    assert_not dish.valid?
  end

  test "uses the shared Perishable expiration status" do
    dish = PreparedDish.new(expires_on: Date.current - 2)
    assert_equal :expired, dish.expiration_status
  end
end
