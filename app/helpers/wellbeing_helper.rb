module WellbeingHelper
  SEX_LABELS = { "female" => "Femme", "male" => "Homme", "other" => "Autre" }.freeze
  ACTIVITY_LABELS = {
    "sedentary" => "Sédentaire", "light" => "Légère", "moderate" => "Modérée",
    "active" => "Active", "very_active" => "Très active"
  }.freeze

  def sex_options = WellbeingProfile::SEXES.map { |sex| [ SEX_LABELS.fetch(sex, sex), sex ] }
  def activity_options = WellbeingProfile::ACTIVITY_LEVELS.map { |level| [ ACTIVITY_LABELS.fetch(level, level), level ] }
end
