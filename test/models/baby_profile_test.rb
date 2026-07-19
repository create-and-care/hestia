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

  test "age_in_months computes whole months since birth" do
    baby = households(:alpha).baby_profiles.build(name: "Lou", born_on: 5.months.ago.to_date - 3.days)
    assert_equal 5, baby.age_in_months
  end

  test "age_in_months is nil without a birth date" do
    baby = households(:alpha).baby_profiles.build(name: "Lou")
    assert_nil baby.age_in_months
  end

  test "rejects a service provider from another household" do
    baby = baby_profiles(:alpha_baby)
    baby.service_provider = service_providers(:beta_provider)
    assert_not baby.valid?
  end

  test "accepts a service provider from the same household" do
    baby = baby_profiles(:alpha_baby)
    baby.service_provider = service_providers(:alpha_plombier)
    assert baby.valid?
  end
end
