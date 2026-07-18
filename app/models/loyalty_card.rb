class LoyaltyCard < ApplicationRecord
  include HouseholdScoped

  FORMATS = %w[barcode qrcode].freeze

  belongs_to :loyalty_brand, optional: true
  belongs_to :address, optional: true

  validates :name, presence: true
  validates :number, presence: true
  validates :code_format, inclusion: { in: FORMATS }
  validate :address_belongs_to_household

  scope :ordered, -> { order(:position, :name) }

  broadcasts_to ->(card) { card.household }

  private
    def address_belongs_to_household
      errors.add(:address, :invalid) if address && address.household_id != household_id
    end
end
