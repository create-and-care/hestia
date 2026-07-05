# Centre de notifications in-app (temps réel, CDC §6). Sert de support commun aux
# rappels Tâches/Calendrier et aux notifications récurrentes (péremption Frigo,
# anniversaire du jour) — plutôt que quatre mécanismes de notification distincts.
class Notification < ApplicationRecord
  KINDS = %w[task_reminder event_reminder fridge_expiry birthday].freeze

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
