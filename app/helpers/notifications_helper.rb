module NotificationsHelper
  KIND_ICONS = {
    "task_reminder" => "✅",
    "event_reminder" => "📅",
    "fridge_expiry" => "🧊",
    "birthday" => "🎂"
  }.freeze

  def notification_icon(notification) = KIND_ICONS.fetch(notification.kind, "🔔")
end
