module VehiclesHelper
  # Maps inspection status to a Ui::BadgeComponent variant. `destructive` (<30 days) now gets its
  # own :destructive variant (added for Tasks/Fridge) instead of collapsing onto the same :warning
  # as `soon` (<90 days) — the spec calls for 4 distinct colors, not 3.
  INSPECTION_BADGE_VARIANTS = {
    expired: :destructive,
    urgent:  :destructive,
    soon:    :warning,
    ok:      :success,
    none:    :secondary
  }.freeze

  def inspection_label(status) = t("vehicles.inspection_statuses.#{status}")
  def inspection_badge_variant(status) = INSPECTION_BADGE_VARIANTS.fetch(status)
  def vehicle_type_label(type) = t("vehicles.types.#{type}", default: type.to_s.humanize)
  def vehicle_type_options = Vehicle::TYPES.map { |type| [ vehicle_type_label(type), type ] }
  def vehicle_type_custom?(type) = type.present? && !Vehicle::TYPES.include?(type)

  def maintenance_entry_type_label(type) = t("vehicle_maintenance_entries.types.#{type}", default: type)
  def maintenance_entry_type_options = VehicleMaintenanceEntry::TYPES.map { |type| [ maintenance_entry_type_label(type), type ] }
end
