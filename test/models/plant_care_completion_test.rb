require "test_helper"

class PlantCareCompletionTest < ActiveSupport::TestCase
  test "requires a completed_on date" do
    completion = plant_care_tasks(:beta_plant_watering).plant_care_completions.build(author: users(:one))
    assert_not completion.valid?
    completion.completed_on = Date.current
    assert completion.valid?
  end

  test "author is optional" do
    completion = plant_care_tasks(:beta_plant_watering).plant_care_completions.build(completed_on: Date.current)
    assert completion.valid?
  end

  test "recent scope orders by completed_on descending" do
    older = plant_care_tasks(:beta_plant_watering).plant_care_completions.create!(completed_on: 2.days.ago.to_date)
    newer = plant_care_tasks(:beta_plant_watering).plant_care_completions.create!(completed_on: 1.day.ago.to_date)
    assert_equal [ newer, older ], PlantCareCompletion.where(id: [ older.id, newer.id ]).recent.to_a
  end
end
