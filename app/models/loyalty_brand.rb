# Catalog of pre-configured loyalty brands (Spec §10.5), built up
# progressively (cf. seed in db/seeds.rb). A card outside the catalog remains
# possible: LoyaltyCard#loyalty_brand is optional.
class LoyaltyBrand < ApplicationRecord
  FORMATS = %w[barcode qrcode].freeze

  has_many :loyalty_cards, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :code_format, inclusion: { in: FORMATS }

  scope :ordered, -> { order(:name) }
end
