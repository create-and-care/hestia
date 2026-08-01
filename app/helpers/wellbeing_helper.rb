module WellbeingHelper
  def sex_options = WellbeingProfile::SEXES.map { |sex| [ t("wellbeing.sexes.#{sex}", default: sex.to_s.humanize), sex ] }
  def activity_options = WellbeingProfile::ACTIVITY_LEVELS.map { |level| [ t("wellbeing.activity_levels.#{level}", default: level.to_s.humanize), level ] }

  # Colors a weight delta badge relative to the user's own goal direction
  # (-1 losing, 0 unknown/maintain, 1 gaining) instead of assuming a drop is
  # always the desired outcome.
  def weight_delta_variant(delta, goal_direction)
    return :secondary if delta.zero? || goal_direction.zero?

    on_track = (goal_direction.negative? && delta.negative?) || (goal_direction.positive? && delta.positive?)
    on_track ? :success : :warning
  end
end
