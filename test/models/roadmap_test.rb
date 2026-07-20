require "test_helper"

class RoadmapTest < ActiveSupport::TestCase
  test "milestones returns a date-or-nil, status, icon, title and items for every entry" do
    milestones = Roadmap.milestones

    assert_equal Roadmap::MILESTONE_SLUGS.size, milestones.size
    milestones.each do |milestone|
      assert milestone[:date].is_a?(Date) || milestone[:date].nil?
      assert_includes %i[done upcoming], milestone[:status]
      assert milestone[:icon].present?
      assert milestone[:title].present?
      assert milestone[:items].is_a?(Array)
      assert milestone[:items].all?(&:present?)
    end
  end

  test "a milestone is done only when it carries a shipped date, upcoming otherwise" do
    Roadmap.milestones.each do |milestone|
      if milestone[:date]
        assert_equal :done, milestone[:status]
      else
        assert_equal :upcoming, milestone[:status]
      end
    end
  end

  test "milestones stay in chronological order, done entries before upcoming ones" do
    dates = Roadmap.milestones.map { |milestone| milestone[:date] }.compact
    assert_equal dates.sort, dates

    statuses = Roadmap.milestones.map { |milestone| milestone[:status] }
    assert_equal statuses.sort_by { |status| status == :done ? 0 : 1 }, statuses
  end

  test "milestones are translated when the locale is French" do
    I18n.with_locale(:fr) do
      assert_equal "Phase 1 — Fondations", Roadmap.milestones.first[:title]
      assert_equal "Hest.AI (Phase 3)", Roadmap.milestones.last[:title]
    end
  end
end
