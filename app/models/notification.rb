# In-app notification center (real-time, Spec §6). Serves as common support for
# Tasks/Calendar reminders and recurring notifications (Fridge expiration,
# birthday of the day) — rather than four separate notification mechanisms.
class Notification < ApplicationRecord
  KINDS = %w[task_reminder event_reminder fridge_expiry birthday external_calendar_sync_failed].freeze

  belongs_to :user
  belongs_to :household
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :kind, inclusion: { in: KINDS }
  validates :title, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  after_create_commit :broadcast_created
  after_update_commit :broadcast_badge

  def read? = read_at.present?

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  private
    def broadcast_created
      broadcast_prepend_to user, :notifications,
        target: "notifications_list", partial: "notifications/notification", locals: { notification: self }
      broadcast_badge
    end

    def broadcast_badge
      broadcast_replace_to user, :notifications,
        target: "notifications_badge", partial: "notifications/badge", locals: { count: user.notifications.unread.count }
    end
end
