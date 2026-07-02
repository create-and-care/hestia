class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :author, class_name: "User"

  validates :content, presence: true

  scope :chronological, -> { order(:created_at) }

  # Temps réel : chaque message est ajouté au fil de la conversation pour les
  # participants connectés (Solid Cable).
  broadcasts_to ->(message) { message.conversation }, inserts_by: :append, target: "messages"
end
