module NotificationsHelper
  # Lucide (https://lucide.dev) icon names, rendered via IconHelper#lucide_icon.
  KIND_ICONS = {
    "task_reminder" => "square-check",
    "event_reminder" => "calendar",
    "fridge_expiry" => "refrigerator",
    "birthday" => "cake"
  }.freeze

  def notification_icon(notification) = lucide_icon(KIND_ICONS.fetch(notification.kind, "bell"), css_class: "size-4")

  # Where clicking a notification should take the user: the notifiable record
  # itself when one was set (task/event reminders), otherwise the module page
  # for kinds whose digest covers several records at once (fridge expiry,
  # birthdays) or has no per-record page at all (a sync failure notice).
  def notification_path(notification)
    case notification.notifiable
    when Task then edit_task_path(notification.notifiable)
    when CalendarEvent then edit_calendar_event_path(notification.notifiable)
    else
      case notification.kind
      when "fridge_expiry" then fridge_path
      when "birthday" then contacts_path
      when "external_calendar_sync_failed" then external_calendar_connections_path
      end
    end
  end
end
