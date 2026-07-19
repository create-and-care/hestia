require "test_helper"

class PlantReferenceTest < ActiveSupport::TestCase
  test "requires a unique common_name" do
    PlantReference.create!(common_name: "Basilic")
    duplicate = PlantReference.new(common_name: "Basilic")
    assert_not duplicate.valid?
  end

  test "plants remain valid without a reference" do
    plant = Plant.new(household: households(:alpha), name: "Ma plante")
    assert plant.valid?
    assert_nil plant.plant_reference
  end

  test "accepts an optional fertilizing note" do
    reference = PlantReference.create!(common_name: "Fougère", fertilizing: "Monthly in summer")
    assert_equal "Monthly in summer", reference.reload.fertilizing
  end
end
