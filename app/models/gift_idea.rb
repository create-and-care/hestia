class GiftIdea < ApplicationRecord
  STATUSES = %w[wanted bought].freeze

  belongs_to :gift_list
  has_many :gift_reservations, dependent: :destroy
  has_one_attached :photo

  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :ordered, -> { order(:created_at) }

  def reserved? = gift_reservations.any?
end
