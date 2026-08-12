class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :author, class_name: "User"
  has_many :message_reactions, dependent: :destroy
  has_one_attached :photo

  ALLOWED_PHOTO_TYPES = %w[image/png image/jpeg image/jpg image/gif image/webp]
  MAX_PHOTO_SIZE = 10.megabytes

  validates :content, presence: true
  validate :photo_must_be_a_valid_image, if: -> { photo.attached? }

  scope :chronological, -> { order(:created_at) }

  # Real-time: each message is appended to the conversation thread for
  # connected participants (Solid Cable).
  broadcasts_to ->(message) { message.conversation }, inserts_by: :append, target: "messages"

  after_create_commit :broadcast_to_conversation_list

  private
    def photo_must_be_a_valid_image
      errors.add(:photo, "must be an image") unless ALLOWED_PHOTO_TYPES.include?(photo.content_type)
      errors.add(:photo, "must be less than 10MB") if photo.byte_size > MAX_PHOTO_SIZE
    end

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
