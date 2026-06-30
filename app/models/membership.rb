class Membership < ApplicationRecord
  ROLES = %w[member admin].freeze

  belongs_to :user
  belongs_to :household

  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :household_id }

  def admin? = role == "admin"
  def member? = role == "member"
end
