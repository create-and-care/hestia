class CirclePostReaction < ApplicationRecord
  belongs_to :circle_post
  belongs_to :user

  validates :emoji, presence: true
  validates :user_id, uniqueness: { scope: :circle_post_id }
end
