require "test_helper"

class WellbeingProfileTest < ActiveSupport::TestCase
  test "bmi from height and weight" do
    profile = WellbeingProfile.new(height: 180)
    assert_equal 21.6, profile.bmi(70)
  end

  test "bmi is nil without a usable height or weight" do
    assert_nil WellbeingProfile.new(height: 0).bmi(70)
    assert_nil WellbeingProfile.new(height: 180).bmi(nil)
  end

  test "rejects an unknown sex" do
    profile = WellbeingProfile.new(user: users(:one), sex: "unknown")
    assert_not profile.valid?
    assert_includes profile.errors[:sex], error_message(:inclusion)
  end

  test "rejects an unknown activity level" do
    profile = WellbeingProfile.new(user: users(:one), activity_level: "unknown")
    assert_not profile.valid?
    assert_includes profile.errors[:activity_level], error_message(:inclusion)
  end

  test "allows a blank sex and activity level" do
    profile = WellbeingProfile.new(user: users(:one))
    assert profile.valid?
  end
end
