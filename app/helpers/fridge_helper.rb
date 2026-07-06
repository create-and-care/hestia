module FridgeHelper
  # Expiration status → badge Tailwind classes (label comes from the fridge.expiration locale scope).
  EXPIRATION_BADGE_CLASSES = {
    expired: "bg-red-100 text-red-700",
    urgent:  "bg-orange-100 text-orange-700",
    soon:    "bg-yellow-100 text-yellow-800",
    ok:      "bg-green-100 text-green-700",
    none:    "bg-gray-100 text-gray-500"
  }.freeze

  def location_label(location)
    t("fridge.locations.#{location}", default: location.to_s.humanize)
  end

  def location_select_options
    FridgeItem::LOCATIONS.map { |location| [ location_label(location), location ] }
  end

  def expiration_label(status)
    t("fridge.expiration.#{status}")
  end

  def expiration_badge_class(status)
    EXPIRATION_BADGE_CLASSES.fetch(status)
  end
end
