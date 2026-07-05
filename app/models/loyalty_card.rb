class LoyaltyCard < ApplicationRecord
  include HouseholdScoped

  FORMATS = %w[barcode qrcode].freeze

  belongs_to :loyalty_brand, optional: true

  validates :name, presence: true
  validates :number, presence: true
  validates :code_format, inclusion: { in: FORMATS }

  scope :ordered, -> { order(:position, :name) }

  broadcasts_to ->(card) { card.household }
end
