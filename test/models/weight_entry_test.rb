require "test_helper"

class WeightEntryTest < ActiveSupport::TestCase
  test "requires recorded_on and weight" do
    entry = WeightEntry.new(user: users(:one))
    assert_not entry.valid?
    assert_includes entry.errors[:recorded_on], error_message(:blank)
    assert_includes entry.errors[:weight], error_message(:blank)
  end

  test "belongs to a user" do
    entry = WeightEntry.new(recorded_on: Date.current, weight: 70)
    assert_not entry.valid?
    assert_includes entry.errors[:user], error_message(:required)
  end

  test "chronological orders from oldest to newest" do
    user = users(:one)
    newer = user.weight_entries.create!(recorded_on: Date.current, weight: 70)
    older = user.weight_entries.create!(recorded_on: 3.days.ago.to_date, weight: 72)

    assert_equal [ older, newer ], user.weight_entries.chronological.to_a
  end
end
