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
end
