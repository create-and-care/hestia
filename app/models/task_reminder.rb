# Rappel personnalisé sur une tâche (CDC §9.3) : date/heure + destinataire.
class TaskReminder < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :remind_at, presence: true

  delegate :household, to: :task

  scope :pending, -> { where(delivered_at: nil) }
  scope :due, -> { pending.where(remind_at: ..Time.current) }
end
