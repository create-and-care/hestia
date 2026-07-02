require "test_helper"

class PetTest < ActiveSupport::TestCase
  test "requires a name" do
    pet = households(:alpha).pets.build
    assert_not pet.valid?
    pet.name = "X"
    assert pet.valid?
  end

  test "age computed from born_on" do
    assert_equal 4, pets(:alpha_dog).age
    assert_nil Pet.new.age
  end

  test "booster_overdue?" do
    overdue = PetVaccination.new(booster_on: Date.current - 1)
    upcoming = PetVaccination.new(booster_on: Date.current + 10)
    assert overdue.booster_overdue?
    assert_not upcoming.booster_overdue?
    assert_not PetVaccination.new.booster_overdue?
  end

  test "destroying a pet destroys its records" do
    pet = pets(:alpha_dog)
    pet.pet_vaccinations.create!(name: "Rage")
    assert_difference -> { PetVaccination.count }, -1 do
      pet.destroy
    end
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).pets, pets(:beta_cat)
  end
end
