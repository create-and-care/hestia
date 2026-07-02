class CircleMembership < ApplicationRecord
  ROLES = %w[member admin].freeze

  belongs_to :circle
  belongs_to :user

  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :circle_id }
end
