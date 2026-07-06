require "test_helper"

class GiftIdeaTest < ActiveSupport::TestCase
  test "requires a name" do
    idea = gift_lists(:alpha_wishlist).gift_ideas.build(status: "wanted")
    assert_not idea.valid?
    idea.name = "Écharpe"
    assert idea.valid?
  end

  test "requires a valid status" do
    idea = gift_lists(:alpha_wishlist).gift_ideas.build(name: "Écharpe", status: "invalid")
    assert_not idea.valid?
  end

  test "reserved? is false without any reservation" do
    assert_not gift_ideas(:alpha_book).reserved?
  end

  test "reserved? is true once a reservation exists" do
    idea = gift_ideas(:alpha_book)
    idea.gift_reservations.create!(reserver_name: "Tante Jeanne")
    assert idea.reserved?
  end

  test "destroying an idea destroys its reservations" do
    idea = gift_ideas(:alpha_book)
    idea.gift_reservations.create!(reserver_name: "Tante Jeanne")

    assert_difference -> { GiftReservation.count }, -1 do
      idea.destroy
    end
  end
end
