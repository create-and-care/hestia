module FridgeHelper
  LOCATION_LABELS = {
    "refrigerateur" => "Réfrigérateur",
    "congelateur" => "Congélateur",
    "garde_manger" => "Garde-manger"
  }.freeze

  # Expiration status → [label, badge Tailwind classes].
  EXPIRATION = {
    expired: [ "Périmé", "bg-red-100 text-red-700" ],
    urgent:  [ "Aujourd'hui / demain", "bg-orange-100 text-orange-700" ],
    soon:    [ "2 à 3 jours", "bg-yellow-100 text-yellow-800" ],
    ok:      [ "Bon", "bg-green-100 text-green-700" ],
    none:    [ "Sans date", "bg-gray-100 text-gray-500" ]
  }.freeze

  def location_label(location)
    LOCATION_LABELS.fetch(location, location.to_s.humanize)
  end

  def location_select_options
    FridgeItem::LOCATIONS.map { |location| [ location_label(location), location ] }
  end

  def expiration_label(status)
    EXPIRATION.fetch(status).first
  end

  def expiration_badge_class(status)
    EXPIRATION.fetch(status).last
  end
end
