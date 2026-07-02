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
end
