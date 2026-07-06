require "test_helper"

class AllergenTestTest < ActiveSupport::TestCase
  test "requires an allergen" do
    allergen_test = baby_profiles(:alpha_baby).allergen_tests.build
    assert_not allergen_test.valid?
    allergen_test.allergen = "Arachide"
    assert allergen_test.valid?
  end

  test "belongs to a baby profile" do
    allergen_test = baby_profiles(:alpha_baby).allergen_tests.create!(allergen: "Arachide")
    assert_equal baby_profiles(:alpha_baby), allergen_test.baby_profile
  end

  test "recent orders by tested_on descending" do
    baby = baby_profiles(:alpha_baby)
    older = baby.allergen_tests.create!(allergen: "Arachide", tested_on: Date.current - 1.week)
    newer = baby.allergen_tests.create!(allergen: "Gluten", tested_on: Date.current - 1.day)
    scoped = baby.allergen_tests.where(id: [ older.id, newer.id ]).recent
    assert_equal [ newer, older ], scoped.to_a
  end
end
