class MessageReaction < ApplicationRecord
  ALLOWED_EMOJIS = %w[👍 ❤️ 😂 🎉 😮].freeze

  belongs_to :message
  belongs_to :user

  validates :emoji, presence: true, inclusion: { in: ALLOWED_EMOJIS }
  validates :user_id, uniqueness: { scope: :message_id }

  # Broadcast message replacement to all conversation participants when reactions change
  after_create_commit :broadcast_message_replacement
  after_update_commit :broadcast_message_replacement
  after_destroy_commit :broadcast_message_replacement

  private
    def broadcast_message_replacement
      message.reload.broadcast_replace_to(
        message.conversation,
        partial: "messages/message",
        locals: { message: message }
      )
    end
end
