module VehiclesHelper
  INSPECTION = {
    expired: [ "Contrôle dépassé", "bg-red-100 text-red-700" ],
    urgent:  [ "Moins de 30 jours", "bg-orange-100 text-orange-700" ],
    soon:    [ "Moins de 90 jours", "bg-yellow-100 text-yellow-800" ],
    ok:      [ "À jour", "bg-green-100 text-green-700" ],
    none:    [ "Non renseigné", "bg-gray-100 text-gray-500" ]
  }.freeze

  TYPE_LABELS = { "car" => "Voiture", "motorcycle" => "Moto" }.freeze

  def inspection_label(status) = INSPECTION.fetch(status).first
  def inspection_badge_class(status) = INSPECTION.fetch(status).last
  def vehicle_type_label(type) = TYPE_LABELS.fetch(type, type.to_s.humanize)
  def vehicle_type_options = Vehicle::TYPES.map { |type| [ vehicle_type_label(type), type ] }
end
