require "test_helper"

class HolidayReferenceTest < ActiveSupport::TestCase
  test "computes Easter Sunday with the anonymous Gregorian algorithm" do
    assert_equal Date.new(2026, 4, 5), HolidayReference.easter_sunday(2026)
    assert_equal Date.new(2027, 3, 28), HolidayReference.easter_sunday(2027)
  end

  test "returns French fixed and movable holidays" do
    holidays = HolidayReference.for("FR", 2026)

    assert_includes holidays.map { |h| h[:date] }, Date.new(2026, 7, 14)
    assert_includes holidays.map { |h| h[:date] }, Date.new(2026, 5, 1)
    # Lundi de Pâques = lendemain de Pâques.
    assert_includes holidays.map { |h| h[:date] }, Date.new(2026, 4, 6)
  end

  test "Belgian and Swiss holidays differ from French national day" do
    fr = HolidayReference.for("FR", 2026).map { |h| h[:date] }
    be = HolidayReference.for("BE", 2026).map { |h| h[:date] }
    ch = HolidayReference.for("CH", 2026).map { |h| h[:date] }

    assert_includes be, Date.new(2026, 7, 21)
    assert_includes ch, Date.new(2026, 8, 1)
    assert_not_includes fr, Date.new(2026, 7, 21)
  end

  test "returns an empty array for an unknown country" do
    assert_equal [], HolidayReference.for("US", 2026)
  end

  test "results are sorted chronologically" do
    holidays = HolidayReference.for("FR", 2026)
    assert_equal holidays.map { |h| h[:date] }.sort, holidays.map { |h| h[:date] }
  end
end
