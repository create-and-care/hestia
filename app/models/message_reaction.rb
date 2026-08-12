class MessageReaction < ApplicationRecord
  ALLOWED_EMOJIS = %w[👍 ❤️ 😂 🎉 😮].freeze

  belongs_to :message
  belongs_to :user

  validates :emoji, presence: true, inclusion: { in: ALLOWED_EMOJIS }
  validates :user_id, uniqueness: { scope: :message_id }

  # Broadcast only reaction counts to all conversation participants when reactions change.
  # We cannot broadcast the full messages/message partial because it contains viewer-specific
  # state (my_reaction, remove button) and Turbo Stream broadcasts render the same HTML for
  # every connected viewer without access to their individual Current.user context.
  after_create_commit :broadcast_reaction_update
  after_update_commit :broadcast_reaction_update
  after_destroy_commit :broadcast_reaction_update

  private
    # find_by rather than the (possibly stale) message association, and
    # nil-guarded: dependent destroy of the parent conversation destroys
    # its messages first, so a reaction's after_destroy_commit can fire
    # after the message row is already gone.
    def broadcast_reaction_update
      message = Message.find_by(id: message_id)
      return unless message

      message.broadcast_replace_to(
        message.conversation,
        target: "message_#{message.id}_reactions",
        partial: "messages/reaction_counts",
        locals: { message: message }
      )
    end
end
