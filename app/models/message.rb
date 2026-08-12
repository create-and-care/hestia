class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :author, class_name: "User"
  has_many :message_reactions, dependent: :destroy
  has_one_attached :photo

  validates :content, presence: true

  scope :chronological, -> { order(:created_at) }

  # Real-time: each message is appended to the conversation thread for
  # connected participants (Solid Cable).
  broadcasts_to ->(message) { message.conversation }, inserts_by: :append, target: "messages"

  after_create_commit :broadcast_to_conversation_list

  private
    # The thread itself (broadcasts_to above) updates live, but without this
    # a participant's /messages list only reflects the new last-message
    # preview and reordering after a full page reload.
    def broadcast_to_conversation_list
      conversation.participants.find_each do |participant|
        broadcast_remove_to(participant, :conversations, target: conversation)
        broadcast_prepend_to(participant, :conversations,
          target: "conversations_list", partial: "conversations/conversation", locals: { conversation: conversation, viewer: participant })
      end
    end
end
