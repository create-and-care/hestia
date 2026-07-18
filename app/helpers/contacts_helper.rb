module ContactsHelper
  PROXIMITY_VARIANTS = {
    today: :destructive,
    week:  :urgent,
    month: :warning,
    later: :secondary,
    none:  :outline
  }.freeze

  def proximity_label(status) = t("contacts.proximity.#{status}")
  def proximity_badge_variant(status) = PROXIMITY_VARIANTS.fetch(status)
end
