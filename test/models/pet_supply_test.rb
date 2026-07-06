require "test_helper"

class PetSupplyTest < ActiveSupport::TestCase
  test "requires a name" do
    supply = pets(:alpha_dog).pet_supplies.build
    assert_not supply.valid?
    supply.name = "Croquettes"
    assert supply.valid?
  end

  test "belongs to a pet" do
    supply = pets(:alpha_dog).pet_supplies.create!(name: "Croquettes")
    assert_equal pets(:alpha_dog), supply.pet
  end

  test "ordered orders by next_order_on then name" do
    pet = pets(:alpha_dog)
    later = pet.pet_supplies.create!(name: "Litière", next_order_on: Date.current + 1.week)
    sooner = pet.pet_supplies.create!(name: "Croquettes", next_order_on: Date.current + 1.day)
    no_date = pet.pet_supplies.create!(name: "Jouet")
    scoped = pet.pet_supplies.where(id: [ later.id, sooner.id, no_date.id ]).ordered
    assert_equal [ sooner, later, no_date ], scoped.to_a
  end

  test "destroyed when its pet is destroyed" do
    pet = pets(:alpha_dog)
    pet.pet_supplies.create!(name: "Croquettes")
    assert_difference -> { PetSupply.count }, -1 do
      pet.destroy
    end
  end
end
