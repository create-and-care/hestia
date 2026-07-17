class Contact < ApplicationRecord
  include HouseholdScoped

  # Entity shared with the Gifts module (Phase 2.d).
  has_many :contact_taggings, dependent: :destroy
  has_many :contact_tags, through: :contact_taggings

  validates :name, presence: true

  broadcasts_to ->(contact) { contact.household }

  def next_birthday(from = Date.current)
    return if born_on.blank?

    this_year = birthday_in(from.year)
    this_year >= from ? this_year : birthday_in(from.year + 1)
  end

  def days_until_birthday(from = Date.current)
    birthday = next_birthday(from)
    (birthday - from).to_i if birthday
  end

  def age(on = Date.current)
    return unless year_known && born_on

    years = on.year - born_on.year
    years -= 1 if birthday_in(on.year) > on
    years
  end

  # Every birthday date landing within [from, to] — used to surface birthdays
  # on the Calendar (month/week/day/list views, Spec §9.2 interconnection).
  def birthdays_between(from, to)
    return [] if born_on.blank?

    (from.year..to.year).filter_map do |year|
      date = birthday_in(year)
      date if (from..to).cover?(date)
    end
  end

  # today / week / month / later / none — recalculated every day (Spec §10.2).
  def proximity_status(from = Date.current)
    days = days_until_birthday(from)
    return :none if days.nil?

    if days.zero?
      :today
    elsif days <= 7
      :week
    elsif days <= 31
      :month
    else
      :later
    end
  end

  private
    def birthday_in(year)
      Date.new(year, born_on.month, born_on.day)
    rescue Date::Error
      Date.new(year, born_on.month, -1) # Feb 29 → last day of the month
    end
end
