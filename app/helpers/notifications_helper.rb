module NotificationsHelper
  # Lucide (https://lucide.dev) icon names, rendered via IconHelper#lucide_icon.
  KIND_ICONS = {
    "task_reminder" => "square-check",
    "event_reminder" => "calendar",
    "fridge_expiry" => "refrigerator",
    "birthday" => "cake"
  }.freeze

  # Blocks the notifications page is grouped into, in display order, each
  # with its header icon and the Tailwind class (spelled out in full so the
  # build's content scanner picks it up — see Ui::ViewToggleComponent for the
  # same pattern) that hides the block when its list container is empty.
  BLOCKS = [
    [ "tasks", "square-check" ],
    [ "calendar", "calendar" ],
    [ "fridge", "refrigerator" ],
    [ "birthdays", "cake" ],
    [ "outdoor", "trees" ],
    [ "global", "layout-grid" ]
  ].freeze

  BLOCK_WRAPPER_CLASSES = {
    "tasks" => "has-[#notifications_list_tasks:empty]:hidden",
    "calendar" => "has-[#notifications_list_calendar:empty]:hidden",
    "fridge" => "has-[#notifications_list_fridge:empty]:hidden",
    "birthdays" => "has-[#notifications_list_birthdays:empty]:hidden",
    "outdoor" => "has-[#notifications_list_outdoor:empty]:hidden",
    "global" => "has-[#notifications_list_global:empty]:hidden"
  }.freeze

  def notification_icon(notification) = lucide_icon(KIND_ICONS.fetch(notification.kind, "bell"), css_class: "size-4")

  def notification_block_label(key) = key == "global" ? t("notifications.index.global") : t("dashboard.show.nav.#{key}")

  # Parenthetical listing the module(s) a "global" notification concerns —
  # nil for notifications shown under their own module's block, which already
  # says so via the block header.
  def notification_modules_label(notification)
    return unless notification.block_key == "global"

    labels = notification.module_keys.map { |key| t("dashboard.show.nav.#{key}") }
    "(#{labels.join(', ')})" if labels.any?
  end

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
