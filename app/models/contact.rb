class Contact < ApplicationRecord
  include HouseholdScoped

  # Entity shared with the Gifts module.
  has_many :contact_taggings, dependent: :destroy
  has_many :contact_tags, through: :contact_taggings
  has_many :gift_lists, dependent: :nullify

  validates :name, presence: true

  # Thresholds for #proximity_status, shared with .birthday_within below.
  WEEK_DAYS = 7
  MONTH_DAYS = 31

  # Contacts whose birthday *may* fall within the next `days` — a deliberate
  # superset, refined by #proximity_status on the handful of rows it returns.
  #
  # A birthday is a (month, day) pair that recurs, so it cannot be compared to
  # a date range directly; the window is enumerated into the pairs it covers
  # and matched on those. Two consequences worth stating:
  #   * the window wraps the year end for free — 30/12 → 02/01 is just six
  #     pairs, not a range Postgres has to reason about;
  #   * 29/02 is added whenever 28/02 is in the window, because #birthday_in
  #     folds a leap-day birthday onto 28/02 in common years. Over-matching is
  #     harmless here (Ruby decides), under-matching would silently drop a
  #     contact from the dashboard three years out of four.
  scope :birthday_within, ->(days) {
    dates = (0..days).map { |offset| Date.current + offset }
    pairs = dates.map { |date| [ date.month, date.day ] }
    pairs << [ 2, 29 ] if pairs.include?([ 2, 28 ])

    # to_char rather than a row constructor over EXTRACT: the row-constructor
    # form needed a placeholder list built by interpolating into the SQL
    # string, which is indistinguishable from an injection at a glance — and
    # Brakeman said so. One bind, one comparison, same index-less scan.
    where("to_char(born_on, 'MM-DD') IN (?)", pairs.map { |month, day| format("%02d-%02d", month, day) })
  }

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
  # on the Calendar (month/week/day/list views).
  def birthdays_between(from, to)
    return [] if born_on.blank?

    (from.year..to.year).filter_map do |year|
      date = birthday_in(year)
      date if (from..to).cover?(date)
    end
  end

  # today / week / month / later / none — recalculated every day.
  def proximity_status(from = Date.current)
    days = days_until_birthday(from)
    return :none if days.nil?

    if days.zero?
      :today
    elsif days <= WEEK_DAYS
      :week
    elsif days <= MONTH_DAYS
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
