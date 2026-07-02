class Conversation < ApplicationRecord
  include HouseholdScoped

  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :messages, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(updated_at: :desc) }
end
