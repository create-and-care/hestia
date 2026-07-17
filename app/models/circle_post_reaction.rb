class CirclePostReaction < ApplicationRecord
  ALLOWED_EMOJIS = %w[👍 ❤️ 😂 🎉 😮].freeze

  belongs_to :circle_post
  belongs_to :user

  validates :emoji, presence: true, inclusion: { in: ALLOWED_EMOJIS }
  validates :user_id, uniqueness: { scope: :circle_post_id }
end
