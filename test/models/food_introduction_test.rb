require "test_helper"

class FoodIntroductionTest < ActiveSupport::TestCase
  test "requires a food" do
    introduction = baby_profiles(:alpha_baby).food_introductions.build
    assert_not introduction.valid?
    introduction.food = "Carotte"
    assert introduction.valid?
  end

  test "belongs to a baby profile" do
    introduction = baby_profiles(:alpha_baby).food_introductions.create!(food: "Carotte")
    assert_equal baby_profiles(:alpha_baby), introduction.baby_profile
  end

  test "recent orders by introduced_on descending" do
    baby = baby_profiles(:alpha_baby)
    older = baby.food_introductions.create!(food: "Carotte", introduced_on: Date.current - 1.week)
    newer = baby.food_introductions.create!(food: "Pomme", introduced_on: Date.current - 1.day)
    scoped = baby.food_introductions.where(id: [ older.id, newer.id ]).recent
    assert_equal [ newer, older ], scoped.to_a
  end
end
