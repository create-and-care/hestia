class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :author, class_name: "User"

  validates :content, presence: true

  scope :chronological, -> { order(:created_at) }

  # Real-time: each message is appended to the conversation thread for
  # connected participants (Solid Cable).
  broadcasts_to ->(message) { message.conversation }, inserts_by: :append, target: "messages"
end
