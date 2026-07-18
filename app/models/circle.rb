class Circle < ApplicationRecord
  # Architectural deviation: a Circle is NOT tied to a household; it groups
  # users (potentially from different households) via CircleMembership (Spec §5, point 1).
  INVITE_CODE_ALPHABET = (("A".."Z").to_a - %w[I O]) + ("2".."9").to_a
  INVITE_CODE_LENGTH = 8

  has_many :circle_memberships, dependent: :destroy
  has_many :members, through: :circle_memberships, source: :user
  has_many :circle_posts, dependent: :destroy

  validates :name, presence: true
  validates :invite_code, presence: true, uniqueness: true

  before_validation :ensure_invite_code, on: :create

  def admin?(user)
    circle_memberships.exists?(user: user, role: "admin")
  end

  # True when `user` is an admin and the only one — used to block leaving
  # (or self-demoting) a circle into a state with no one left to manage it.
  def only_admin?(user)
    admin?(user) && circle_memberships.where(role: "admin").count == 1
  end

  def self.generate_invite_code
    loop do
      code = Array.new(INVITE_CODE_LENGTH) { INVITE_CODE_ALPHABET.sample }.join
      break code unless exists?(invite_code: code)
    end
  end

  private
    def ensure_invite_code
      self.invite_code ||= self.class.generate_invite_code
    end
end
