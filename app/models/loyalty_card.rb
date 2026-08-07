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
    # Only when the link itself changed. Re-reading the association on every
    # save meant one query per row through a drag-and-drop reorder, which is
    # what Bullet was reporting — and re-answering a question whose inputs
    # cannot have moved.
    def address_belongs_to_household
      return unless new_record? || will_save_change_to_address_id? || will_save_change_to_household_id?

      errors.add(:address, :invalid) if address && address.household_id != household_id
    end
end
