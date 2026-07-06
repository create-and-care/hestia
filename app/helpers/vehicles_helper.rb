module VehiclesHelper
  INSPECTION_CLASSES = {
    expired: "bg-red-100 text-red-700",
    urgent:  "bg-orange-100 text-orange-700",
    soon:    "bg-yellow-100 text-yellow-800",
    ok:      "bg-green-100 text-green-700",
    none:    "bg-gray-100 text-gray-500"
  }.freeze

  def inspection_label(status) = t("vehicles.inspection_statuses.#{status}")
  def inspection_badge_class(status) = INSPECTION_CLASSES.fetch(status)
  def vehicle_type_label(type) = t("vehicles.types.#{type}", default: type.to_s.humanize)
  def vehicle_type_options = Vehicle::TYPES.map { |type| [ vehicle_type_label(type), type ] }
end
