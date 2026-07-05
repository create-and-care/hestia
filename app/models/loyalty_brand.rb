# Catalogue d'enseignes de fidélité pré-configurées (CDC §10.5), constitué
# progressivement (cf. seed dans db/seeds.rb). Une carte hors catalogue reste
# possible : LoyaltyCard#loyalty_brand est optionnel.
class LoyaltyBrand < ApplicationRecord
  FORMATS = %w[barcode qrcode].freeze

  has_many :loyalty_cards, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :code_format, inclusion: { in: FORMATS }

  scope :ordered, -> { order(:name) }
end
