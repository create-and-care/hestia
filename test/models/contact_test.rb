require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "requires a name" do
    contact = households(:alpha).contacts.build
    assert_not contact.valid?
    contact.name = "X"
    assert contact.valid?
  end

  test "days_until_birthday and proximity for an upcoming birthday" do
    contact = Contact.new(name: "X", born_on: (Date.current + 3.days).change(year: 1980), year_known: true)
    assert_equal 3, contact.days_until_birthday
    assert_equal :week, contact.proximity_status
  end

  test "birthday today with age when the year is known" do
    contact = Contact.new(name: "X", born_on: 25.years.ago.to_date, year_known: true)
    assert_equal 0, contact.days_until_birthday
    assert_equal :today, contact.proximity_status
    assert_equal 25, contact.age
  end

  test "no age when the year is unknown" do
    contact = Contact.new(name: "X", born_on: Date.new(2000, 1, 1), year_known: false)
    assert_nil contact.age
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).contacts, contacts(:beta_friend)
  end

  test "birthdays_between finds the birthday date within a range" do
    contact = Contact.new(name: "X", born_on: Date.new(1990, 8, 15))
    dates = contact.birthdays_between(Date.new(2026, 8, 1), Date.new(2026, 8, 31))
    assert_equal [ Date.new(2026, 8, 15) ], dates
  end

  test "birthdays_between returns nothing outside the range" do
    contact = Contact.new(name: "X", born_on: Date.new(1990, 8, 15))
    assert_empty contact.birthdays_between(Date.new(2026, 9, 1), Date.new(2026, 9, 30))
  end

  test "birthdays_between handles a Feb 29 birthday in a non-leap year" do
    contact = Contact.new(name: "X", born_on: Date.new(2000, 2, 29))
    dates = contact.birthdays_between(Date.new(2026, 2, 1), Date.new(2026, 2, 28))
    assert_equal [ Date.new(2026, 2, 28) ], dates
  end

  # ── birthday_within (PERF-04) ────────────────────────────────────────────
  test "birthday_within matches on the day and month, not on the birth year" do
    household = households(:alpha)
    household.contacts.destroy_all
    soon = household.contacts.create!(name: "Bientôt", born_on: Date.new(1985, Date.current.month, Date.current.day) + 3)
    household.contacts.create!(name: "Plus tard", born_on: Date.current + 3.months)
    household.contacts.create!(name: "Sans date", born_on: nil)

    assert_equal [ soon ], household.contacts.birthday_within(Contact::WEEK_DAYS).to_a
  end

  test "birthday_within wraps around the end of the year" do
    travel_to Date.new(2026, 12, 30) do
      household = households(:alpha)
      household.contacts.destroy_all
      new_year = household.contacts.create!(name: "Jour de l'an", born_on: Date.new(1990, 1, 2))

      assert_equal [ new_year ], household.contacts.birthday_within(Contact::WEEK_DAYS).to_a
    end
  end

  # #birthday_in folds 29/02 onto 28/02 in a common year, so the SQL window has
  # to reach for it too — otherwise these contacts vanish from the dashboard
  # three years out of four.
  test "birthday_within reaches a Feb 29 birthday from a common year" do
    travel_to Date.new(2026, 2, 26) do
      household = households(:alpha)
      household.contacts.destroy_all
      leapling = household.contacts.create!(name: "Bissextile", born_on: Date.new(2000, 2, 29))

      assert_includes household.contacts.birthday_within(Contact::WEEK_DAYS), leapling
      assert_equal :week, leapling.proximity_status
    end
  end
end
