module FridgeHelper
  # Expiration status → Ui::BadgeComponent variant (label comes from the fridge.expiration locale scope).
  EXPIRATION_BADGE_VARIANTS = {
    expired:      :destructive,
    destructive:  :destructive,
    soon:         :warning,
    ok:           :success,
    none:         :secondary
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

  def expiration_badge_variant(status)
    EXPIRATION_BADGE_VARIANTS.fetch(status)
  end
end
