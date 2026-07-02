class GiftList < ApplicationRecord
  include HouseholdScoped

  PERSPECTIVES = %w[receive give].freeze

  belongs_to :contact, optional: true # destinataire pour les listes « offrir »
  has_one :gift_list_share, dependent: :destroy
  has_many :gift_ideas, dependent: :destroy

  validates :name, presence: true
  validates :perspective, inclusion: { in: PERSPECTIVES }

  scope :ordered, -> { order(:name) }

  def shared? = gift_list_share.present?
end
