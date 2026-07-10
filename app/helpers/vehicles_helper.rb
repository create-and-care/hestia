module VehiclesHelper
  # Maps inspection status to a Ui::BadgeComponent variant. `urgent` and `soon`
  # both collapse onto :warning since BadgeComponent has no intermediate
  # (orange vs yellow) variant between :warning and :destructive.
  INSPECTION_BADGE_VARIANTS = {
    expired: :destructive,
    urgent:  :warning,
    soon:    :warning,
    ok:      :success,
    none:    :secondary
  }.freeze

  def inspection_label(status) = t("vehicles.inspection_statuses.#{status}")
  def inspection_badge_variant(status) = INSPECTION_BADGE_VARIANTS.fetch(status)
  def vehicle_type_label(type) = t("vehicles.types.#{type}", default: type.to_s.humanize)
  def vehicle_type_options = Vehicle::TYPES.map { |type| [ vehicle_type_label(type), type ] }
end
