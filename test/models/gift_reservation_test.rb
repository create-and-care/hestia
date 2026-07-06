require "test_helper"

class GiftReservationTest < ActiveSupport::TestCase
  test "requires a gift idea" do
    reservation = GiftReservation.new
    assert_not reservation.valid?
  end

  test "display_name uses the reserver name when present" do
    reservation = gift_ideas(:alpha_book).gift_reservations.create!(reserver_name: "Tante Jeanne")
    assert_equal "Tante Jeanne", reservation.display_name
  end

  test "display_name falls back to Anonyme when the reserver name is blank" do
    reservation = gift_ideas(:alpha_book).gift_reservations.create!(reserver_name: "")
    assert_equal "Anonyme", reservation.display_name

    anonymous = gift_ideas(:alpha_book).gift_reservations.create!
    assert_equal "Anonyme", anonymous.display_name
  end
end
