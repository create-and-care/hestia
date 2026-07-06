module WellbeingHelper
  def sex_options = WellbeingProfile::SEXES.map { |sex| [ t("wellbeing.sexes.#{sex}", default: sex.to_s.humanize), sex ] }
  def activity_options = WellbeingProfile::ACTIVITY_LEVELS.map { |level| [ t("wellbeing.activity_levels.#{level}", default: level.to_s.humanize), level ] }
end
