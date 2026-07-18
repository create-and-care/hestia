class Conversation < ApplicationRecord
  include HouseholdScoped

  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :messages, dependent: :destroy
  belongs_to :subject, polymorphic: true, optional: true

  validates :name, presence: true

  scope :ordered, -> { order(updated_at: :desc) }
  scope :unread_for, ->(user) {
    joins(:conversation_participants, :messages)
      .where(conversation_participants: { user_id: user.id })
      .where("messages.created_at > COALESCE(conversation_participants.last_read_at, '1970-01-01')")
  }

  def unread_for?(user)
    participant = conversation_participants.detect { |cp| cp.user_id == user.id }
    return false unless participant

    last_message_at = messages.map(&:created_at).max
    last_message_at.present? && (participant.last_read_at.nil? || last_message_at > participant.last_read_at)
  end
end
