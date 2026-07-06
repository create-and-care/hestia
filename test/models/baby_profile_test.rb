require "test_helper"

class BabyProfileTest < ActiveSupport::TestCase
  test "requires a name" do
    baby = households(:alpha).baby_profiles.build
    assert_not baby.valid?
    baby.name = "Sam"
    assert baby.valid?
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).baby_profiles, baby_profiles(:beta_baby)
  end

  test "ordered orders by name" do
    household = households(:alpha)
    zoe = household.baby_profiles.create!(name: "Zoé")
    ana = household.baby_profiles.create!(name: "Ana")
    scoped = household.baby_profiles.where(id: [ zoe.id, ana.id ]).ordered
    assert_equal [ ana, zoe ], scoped.to_a
  end

  test "destroying a baby profile destroys its records" do
    baby = baby_profiles(:alpha_baby)
    baby.feeding_sessions.create!(kind: "bottle")
    baby.food_introductions.create!(food: "Carotte")
    baby.allergen_tests.create!(allergen: "Arachide")

    assert_difference -> { FeedingSession.count }, -1 do
      assert_difference -> { FoodIntroduction.count }, -1 do
        assert_difference -> { AllergenTest.count }, -1 do
          baby.destroy
        end
      end
    end
  end
end
