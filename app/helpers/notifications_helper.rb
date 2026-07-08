module NotificationsHelper
  # Lucide (https://lucide.dev) icon names, rendered via IconHelper#lucide_icon.
  KIND_ICONS = {
    "task_reminder" => "square-check",
    "event_reminder" => "calendar",
    "fridge_expiry" => "refrigerator",
    "birthday" => "cake"
  }.freeze

  def notification_icon(notification) = lucide_icon(KIND_ICONS.fetch(notification.kind, "bell"), css_class: "size-4")
end
