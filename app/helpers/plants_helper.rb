module PlantsHelper
  CARE_BADGE_VARIANTS = { overdue: :destructive, soon: :warning, ok: :success, none: :secondary }.freeze

  def care_type_label(type) = t("plant_care_tasks.types.#{type}", default: type)
  def care_type_options = PlantCareTask::CARE_TYPES.map { |type| [ care_type_label(type), type ] }

  def care_frequency_label(frequency) = t("plant_care_tasks.frequencies.#{frequency}", default: frequency)
  def care_frequency_options = Recurrence::PERIODS.keys.map { |frequency| [ care_frequency_label(frequency), frequency ] }

  def care_status_label(status) = t("plants.care_statuses.#{status}")
  def care_status_badge_variant(status) = CARE_BADGE_VARIANTS.fetch(status)
end
