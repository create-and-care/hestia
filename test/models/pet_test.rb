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

  test "can have a photo attached" do
    pet = pets(:alpha_dog)
    pet.photo.attach(io: File.open(Rails.root.join("test/fixtures/files/sample.png")), filename: "sample.png", content_type: "image/png")
    assert pet.photo.attached?
  end

  test "rejects a service provider from another household" do
    pet = households(:alpha).pets.build(name: "X", service_provider: service_providers(:beta_provider))
    assert_not pet.valid?
    assert_includes pet.errors[:service_provider], error_message(:invalid)
  end

  test "accepts a service provider from the same household" do
    pet = households(:alpha).pets.build(name: "X", service_provider: service_providers(:alpha_plombier))
    assert pet.valid?
  end
end
