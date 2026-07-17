class CirclePost < ApplicationRecord
  PAGE_SIZE = 25

  belongs_to :circle
  belongs_to :author, class_name: "User"
  has_many :circle_post_reactions, dependent: :destroy
  has_one_attached :photo

  validates :body, presence: true

  scope :chronological, -> { order(created_at: :desc) }

  broadcasts_to ->(post) { post.circle }, inserts_by: :prepend, target: "circle_posts"

  def deletable_by?(user)
    author_id == user.id || circle.admin?(user)
  end
end
