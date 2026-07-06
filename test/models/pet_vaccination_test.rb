require "test_helper"

class PetVaccinationTest < ActiveSupport::TestCase
  test "requires a name" do
    vaccination = pets(:alpha_dog).pet_vaccinations.build
    assert_not vaccination.valid?
    vaccination.name = "Rage"
    assert vaccination.valid?
  end

  test "belongs to a pet" do
    vaccination = pets(:alpha_dog).pet_vaccinations.create!(name: "Rage")
    assert_equal pets(:alpha_dog), vaccination.pet
  end

  test "booster_overdue? compares booster_on to today" do
    assert PetVaccination.new(booster_on: Date.current - 1).booster_overdue?
    assert_not PetVaccination.new(booster_on: Date.current + 1).booster_overdue?
    assert_not PetVaccination.new.booster_overdue?
  end

  test "ordered orders by booster_on then injected_on" do
    pet = pets(:alpha_dog)
    later = pet.pet_vaccinations.create!(name: "Rage", booster_on: Date.current + 1.year)
    sooner = pet.pet_vaccinations.create!(name: "Leptospirose", booster_on: Date.current + 1.month)
    scoped = pet.pet_vaccinations.where(id: [ later.id, sooner.id ]).ordered
    assert_equal [ sooner, later ], scoped.to_a
  end

  test "destroyed when its pet is destroyed" do
    pet = pets(:alpha_dog)
    pet.pet_vaccinations.create!(name: "Rage")
    assert_difference -> { PetVaccination.count }, -1 do
      pet.destroy
    end
  end
end
