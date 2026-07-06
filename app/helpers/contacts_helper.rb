module ContactsHelper
  PROXIMITY_CLASSES = {
    today: "bg-red-100 text-red-700",
    week:  "bg-orange-100 text-orange-700",
    month: "bg-yellow-100 text-yellow-800",
    later: "bg-gray-100 text-gray-600",
    none:  "bg-gray-100 text-gray-400"
  }.freeze

  def proximity_label(status) = t("contacts.proximity.#{status}")
  def proximity_badge_class(status) = PROXIMITY_CLASSES.fetch(status)
end
