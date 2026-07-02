require "test_helper"

class AddressTest < ActiveSupport::TestCase
  test "requires a name and a valid type" do
    address = households(:alpha).addresses.build(address_type: "restaurant")
    assert_not address.valid?
    address.name = "X"
    assert address.valid?
    address.address_type = "invalide"
    assert_not address.valid?
  end

  test "rating must be within 1..5" do
    address = households(:alpha).addresses.build(name: "X", address_type: "bar", rating: 6)
    assert_not address.valid?
  end

  test "maps_url from coordinates or address" do
    address = Address.new(latitude: 48.8, longitude: 2.3)
    assert_includes address.maps_url, "mlat=48.8"
    assert_includes Address.new(full_address: "Paris").maps_url, "search"
    assert_nil Address.new.maps_url
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).addresses, addresses(:beta_place)
  end
end
