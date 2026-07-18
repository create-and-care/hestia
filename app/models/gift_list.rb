class GiftList < ApplicationRecord
  include HouseholdScoped

  PERSPECTIVES = %w[receive give].freeze

  belongs_to :contact, optional: true # recipient for the "give" lists
  belongs_to :created_by, class_name: "User", optional: true
  has_one :gift_list_share, dependent: :destroy
  has_many :gift_ideas, dependent: :destroy

  validates :name, presence: true
  validates :perspective, inclusion: { in: PERSPECTIVES }

  before_save :ensure_creator_visible

  scope :ordered, -> { order(:name) }

  def shared? = gift_list_share.present?

  # Private lists ("preparing a surprise", Spec §12.1) are visible only to
  # the creator and whoever they explicitly included — everyone else in the
  # household is excluded, unlike every other household-scoped resource.
  def visible_to?(user)
    return true unless restricted?
    created_by_id == user.id || visible_to_ids.include?(user.id)
  end

  private
    # The creator can never accidentally lock themselves out of a list they
    # made private (Spec §12.1 business rule).
    def ensure_creator_visible
      return if created_by_id.nil?
      self.visible_to_ids = (visible_to_ids + [ created_by_id ]).uniq
    end
end
