require "test_helper"

class PlantCareTaskTest < ActiveSupport::TestCase
  test "sets an initial due date on create" do
    task = plants(:alpha_rose).plant_care_tasks.create!(care_type: "watering", frequency: "weekly")
    assert_equal Date.current, task.next_due_on
  end

  test "overdue? reflects the due date" do
    assert plant_care_tasks(:alpha_rose_watering_overdue).overdue?
    assert_not plant_care_tasks(:alpha_rose_repotting).overdue?
  end

  test "due_soon? is true within the next few days but not overdue" do
    task = plants(:alpha_rose).plant_care_tasks.create!(care_type: "watering", frequency: "daily", next_due_on: 1.day.from_now.to_date)
    assert task.due_soon?
    assert_not task.overdue?
  end

  test "status reflects overdue, due soon, and ok" do
    assert_equal :overdue, plant_care_tasks(:alpha_rose_watering_overdue).status
    assert_equal :ok, plant_care_tasks(:alpha_rose_repotting).status
  end

  test "complete! records a completion and advances the due date" do
    task = plant_care_tasks(:beta_plant_watering) # weekly, interval 1
    assert_difference -> { task.plant_care_completions.count }, 1 do
      task.complete!(author: users(:one), on: Date.current)
    end
    assert_equal Date.current + 1.week, task.reload.next_due_on
  end

  test "yearly recurrence advances by years, respecting the interval" do
    task = plant_care_tasks(:alpha_rose_repotting) # yearly, interval 2
    task.complete!(author: users(:one), on: Date.new(2026, 3, 1))
    assert_equal Date.new(2028, 3, 1), task.next_due_on
  end

  test "is scoped to its plant" do
    assert_not_includes plants(:alpha_rose).plant_care_tasks, plant_care_tasks(:beta_plant_watering)
  end
end
