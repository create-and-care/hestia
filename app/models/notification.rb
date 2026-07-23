# In-app notification center (real-time). Serves as common support for
# Tasks/Calendar reminders and recurring notifications (Fridge expiration,
# birthday of the day) — rather than four separate notification mechanisms.
class Notification < ApplicationRecord
  KINDS = %w[task_reminder event_reminder fridge_expiry birthday external_calendar_sync_failed plant_care_due].freeze

  # Sidebar module(s) (see SidebarHelper::SIDEBAR_GROUPS nav keys) each kind
  # belongs to — drives the grouped blocks on the notifications page. A kind
  # mapped to zero or several modules falls into the catch-all "global" block.
  MODULE_KEYS_BY_KIND = {
    "task_reminder" => %w[tasks],
    "event_reminder" => %w[calendar],
    "fridge_expiry" => %w[fridge],
    "birthday" => %w[birthdays],
    "plant_care_due" => %w[outdoor],
    "external_calendar_sync_failed" => %w[calendar]
  }.freeze

  belongs_to :user
  belongs_to :household
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :kind, inclusion: { in: KINDS }
  validates :title, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  after_create_commit :broadcast_created
  after_update_commit :broadcast_updated

  def read? = read_at.present?

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  def module_keys = MODULE_KEYS_BY_KIND.fetch(kind, [])

  # The block this notification is grouped under on the notifications page.
  def block_key
    module_keys.one? ? module_keys.first : "global"
  end

  private
    def broadcast_created
      # Prepends to both the topbar popover's flat list (id="notifications_list",
      # see shared/_notifications) and the full /notifications page's grouped
      # block for this notification's kind — a target that doesn't exist on
      # the current page is simply a no-op, so both stay in sync regardless
      # of which one the user has open.
      broadcast_prepend_to user, :notifications,
        target: "notifications_list", partial: "notifications/notification", locals: { notification: self }
      broadcast_prepend_to user, :notifications,
        target: "notifications_list_#{block_key}", partial: "notifications/notification", locals: { notification: self }
      broadcast_badge
    end

    # Keeps every other open tab/device (popover and the full /notifications
    # page alike) in sync when this notification is marked read elsewhere —
    # the response to the request that triggered the change updates its own
    # view directly (see NotificationsController), this is for everyone else.
    def broadcast_updated
      broadcast_replace_to user, :notifications,
        target: self, partial: "notifications/notification", locals: { notification: self }
      broadcast_badge
    end

    def broadcast_badge
      broadcast_replace_to user, :notifications,
        target: "notifications_badge", partial: "notifications/badge", locals: { count: user.notifications.unread.count }
    end
end
