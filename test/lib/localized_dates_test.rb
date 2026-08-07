require "test_helper"

# Guards I18N-03: no `strftime` for anything a user reads.
#
# The 51 call sites this replaces all spelled a French order by hand —
# "%d/%m/%Y" — and served it unchanged to an English-speaking user, for whom
# 07/08/2026 is 8 July. That is not an untranslated string, it is a wrong date,
# and nothing about it looks wrong in review. Hence a rule rather than a habit.
#
# `l()` is not merely the localized spelling: it also picks the format by the
# object's class, so a Date and a Time can share one name and still render what
# each of them should.
class LocalizedDatesTest < ActiveSupport::TestCase
  # The formats that describe a machine, not a reader, and must stay literal.
  ALLOWED = {
    # <input type="datetime-local"> only accepts this exact shape.
    "%Y-%m-%dT%H:%M" => "an HTML datetime-local value",
    # ?month= in the calendar's own URLs, parsed back by the controller.
    "%Y-%m" => "a URL parameter",
    # CalDAV's time-range filter, defined by RFC 4791.
    "%Y%m%dT%H%M%SZ" => "a CalDAV protocol value"
  }.freeze

  STRFTIME = /\.strftime\(\s*["']([^"']*)["']\s*\)/

  test "no display strftime in a view, a helper, a component or a service" do
    offenders = source_files.flat_map do |path|
      File.readlines(path).filter_map.with_index(1) do |line, number|
        format = line[STRFTIME, 1]
        next if format.nil? || ALLOWED.key?(format)

        "#{relative_path(path)}:#{number} — strftime(#{format.inspect})"
      end
    end

    assert_empty offenders, <<~MESSAGE
      strftime found where a user will read the result. Use l() with a format
      from config/locales/{en,fr}/formats.yml instead — :numeric,
      :numeric_short, :numeric_compact, :weekday_numeric or :hour_minute:

        #{offenders.join("\n  ")}

      If the string is for a machine rather than a reader, add its format to
      LocalizedDatesTest::ALLOWED with the reason.
    MESSAGE
  end

  # The names the guard sends people to have to exist in both locales, or the
  # message above is an invitation to write a NoMethodError.
  test "every format the guard recommends exists in both locales" do
    %i[numeric numeric_short numeric_compact weekday_numeric].each do |format|
      %i[en fr].each do |locale|
        assert I18n.t("date.formats.#{format}", locale: locale, default: nil).present?,
          "date.formats.#{format} is missing from #{locale}"
      end
    end

    %i[numeric numeric_short weekday_numeric hour_minute].each do |format|
      %i[en fr].each do |locale|
        assert I18n.t("time.formats.#{format}", locale: locale, default: nil).present?,
          "time.formats.#{format} is missing from #{locale}"
      end
    end
  end

  # The whole point: the same call renders a different order per locale. If
  # these ever agree, a format has been hard-coded again somewhere upstream.
  test "a numeric date reads differently in English and in French" do
    date = Date.new(2026, 8, 7)

    assert_equal "08/07/2026", I18n.l(date, format: :numeric, locale: :en)
    assert_equal "07/08/2026", I18n.l(date, format: :numeric, locale: :fr)
  end

  private

    def source_files
      Dir.glob(Rails.root.join("app/{views,helpers,components,services,mailers}/**/*.{erb,rb}"))
    end

    def relative_path(path)
      path.to_s.sub("#{Rails.root}/", "")
    end
end
