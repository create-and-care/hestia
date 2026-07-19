require "test_helper"

class RoadmapTest < ActiveSupport::TestCase
  test "phases returns a name, detail and status for every phase" do
    phases = Roadmap.phases

    assert_equal Roadmap::PHASE_SLUGS.size, phases.size
    phases.each do |phase|
      assert phase[:name].present?
      assert phase[:detail].present?
      assert_includes %i[done partial todo], phase[:status]
    end
  end

  test "improvements returns a category, emoji and items for every group" do
    improvements = Roadmap.improvements

    assert_equal Roadmap::IMPROVEMENT_SLUGS_AND_EMOJIS.size, improvements.size
    improvements.each do |group|
      assert group[:category].present?
      assert group[:emoji].present?
      assert group[:items].is_a?(Array)
      assert group[:items].all?(&:present?)
    end
  end

  test "phases and improvements are translated when the locale is French" do
    I18n.with_locale(:fr) do
      assert_equal "Phase 1 — Fondations", Roadmap.phases.first[:name]
      assert_equal "Tableau de bord & expérience transverse", Roadmap.improvements.first[:category]
    end
  end
end
