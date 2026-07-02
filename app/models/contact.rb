class Contact < ApplicationRecord
  include HouseholdScoped

  # Entité partagée avec le module Cadeaux (Phase 2.d).
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

  # today / week / month / later / none — recalculé chaque jour (CDC §10.2).
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
      Date.new(year, born_on.month, -1) # 29 février → dernier jour du mois
    end
end
