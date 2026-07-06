# Reference table of public holidays for France / Belgium / Switzerland for the Calendar
# (Spec §9.2, §16). Computed (computus algorithm for Easter), with no external
# dependency or content to maintain. Switzerland is simplified to the common
# federal base: several public holidays vary by canton and are not covered here.
class HolidayReference
  COUNTRIES = %w[FR BE CH].freeze

  def self.for(country, year)
    return [] unless COUNTRIES.include?(country.to_s)

    new(country.to_s, year.to_i).holidays
  end

  # Anonymous Gregorian algorithm (Meeus/Jones/Butcher) for calculating Easter.
  def self.easter_sunday(year)
    a = year % 19
    b = year / 100
    c = year % 100
    d = b / 4
    e = b % 4
    f = (b + 8) / 25
    g = (b - f + 1) / 3
    h = (19 * a + b - d - g + 15) % 30
    i = c / 4
    k = c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) / 451
    month = (h + l - 7 * m + 114) / 31
    day = ((h + l - 7 * m + 114) % 31) + 1
    Date.new(year, month, day)
  end

  def initialize(country, year)
    @country = country
    @year = year
    @easter = self.class.easter_sunday(year)
  end

  def holidays
    case @country
    when "FR" then fr_holidays
    when "BE" then be_holidays
    when "CH" then ch_holidays
    else []
    end.sort_by { |holiday| holiday[:date] }
  end

  private
    def fixed(month, day, name) = { date: Date.new(@year, month, day), name: name }
    def relative(offset, name) = { date: @easter + offset, name: name }

    def fr_holidays
      [
        fixed(1, 1, "Jour de l'An"),
        relative(1, "Lundi de Pâques"),
        fixed(5, 1, "Fête du Travail"),
        fixed(5, 8, "Victoire 1945"),
        relative(39, "Ascension"),
        relative(50, "Lundi de Pentecôte"),
        fixed(7, 14, "Fête nationale"),
        fixed(8, 15, "Assomption"),
        fixed(11, 1, "Toussaint"),
        fixed(11, 11, "Armistice"),
        fixed(12, 25, "Noël")
      ]
    end

    def be_holidays
      [
        fixed(1, 1, "Nouvel An"),
        relative(1, "Lundi de Pâques"),
        fixed(5, 1, "Fête du Travail"),
        relative(39, "Ascension"),
        relative(50, "Lundi de Pentecôte"),
        fixed(7, 21, "Fête nationale"),
        fixed(8, 15, "Assomption"),
        fixed(11, 1, "Toussaint"),
        fixed(11, 11, "Armistice"),
        fixed(12, 25, "Noël")
      ]
    end

    def ch_holidays
      [
        fixed(1, 1, "Nouvel An"),
        relative(-2, "Vendredi saint"),
        relative(1, "Lundi de Pâques"),
        relative(39, "Ascension"),
        relative(50, "Lundi de Pentecôte"),
        fixed(8, 1, "Fête nationale"),
        fixed(12, 25, "Noël"),
        fixed(12, 26, "Saint-Étienne")
      ]
    end
end
