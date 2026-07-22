require "test_helper"

class PlantTest < ActiveSupport::TestCase
  test "requires a name" do
    plant = households(:alpha).plants.build
    assert_not plant.valid?
    plant.name = "Rosier"
    assert plant.valid?
  end

  test "plant_reference is optional" do
    plant = households(:alpha).plants.build(name: "Test")
    assert plant.valid?
    assert_nil plant.plant_reference
  end

  test "ordered scope orders by name" do
    zinnia = households(:alpha).plants.create!(name: "Zinnia")
    aloe = households(:alpha).plants.create!(name: "Aloe")
    assert_equal [ aloe, zinnia ], Plant.where(id: [ aloe.id, zinnia.id ]).ordered.to_a
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).plants, plants(:beta_plant)
  end

  test "accepts an optional photo attachment" do
    plant = plants(:alpha_rose)
    assert_not plant.photo.attached?
    plant.photo.attach(io: File.open(file_fixture("sample.png")), filename: "sample.png", content_type: "image/png")
    assert plant.photo.attached?
  end

  test "care_status is none without any care task" do
    plant = households(:alpha).plants.create!(name: "Sans entretien")
    assert_equal :none, plant.care_status
  end

  test "care_status is overdue when any care task is overdue" do
    assert_equal :overdue, plants(:alpha_rose).care_status
  end

  test "care_status is ok when no care task is overdue or due soon" do
    plant = households(:alpha).plants.create!(name: "En pleine forme")
    plant.plant_care_tasks.create!(care_type: "watering", frequency: "weekly", next_due_on: 3.weeks.from_now.to_date)
    assert_equal :ok, plant.care_status
  end
end
