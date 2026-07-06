require "test_helper"

class PetTreatmentTest < ActiveSupport::TestCase
  test "requires a name" do
    treatment = pets(:alpha_dog).pet_treatments.build
    assert_not treatment.valid?
    treatment.name = "Vermifuge"
    assert treatment.valid?
  end

  test "belongs to a pet" do
    treatment = pets(:alpha_dog).pet_treatments.create!(name: "Vermifuge")
    assert_equal pets(:alpha_dog), treatment.pet
  end

  test "ordered orders by name" do
    pet = pets(:alpha_dog)
    second = pet.pet_treatments.create!(name: "Vermifuge")
    first = pet.pet_treatments.create!(name: "Anti-puces")
    scoped = pet.pet_treatments.where(id: [ first.id, second.id ]).ordered
    assert_equal [ first, second ], scoped.to_a
  end

  test "destroyed when its pet is destroyed" do
    pet = pets(:alpha_dog)
    pet.pet_treatments.create!(name: "Vermifuge")
    assert_difference -> { PetTreatment.count }, -1 do
      pet.destroy
    end
  end
end
