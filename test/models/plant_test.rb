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

  # The dashboard used to load every plant with its whole care schedule to keep
  # five of them; `needing_care` is the same question asked of the database.
  test "needing_care keeps only plants with a care task due or overdue" do
    household = households(:alpha)
    household.plants.destroy_all
    late = household.plants.create!(name: "Assoiffée")
    late.plant_care_tasks.create!(care_type: "watering", frequency: "weekly", next_due_on: 2.days.ago.to_date)
    fine = household.plants.create!(name: "Tranquille")
    fine.plant_care_tasks.create!(care_type: "watering", frequency: "weekly", next_due_on: 3.weeks.from_now.to_date)
    household.plants.create!(name: "Sans entretien")

    assert_equal [ late ], household.plants.needing_care.to_a
    assert_equal :ok, fine.care_status
  end

  test "needing_care lists a plant once however many of its tasks are due" do
    household = households(:alpha)
    household.plants.destroy_all
    plant = household.plants.create!(name: "Exigeante")
    plant.plant_care_tasks.create!(care_type: "watering", frequency: "weekly", next_due_on: Date.current)
    plant.plant_care_tasks.create!(care_type: "misting", frequency: "daily", next_due_on: 1.day.ago.to_date)

    assert_equal [ plant ], household.plants.needing_care.to_a
  end
end
