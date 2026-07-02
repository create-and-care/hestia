class WineCellar < ApplicationRecord
  include HouseholdScoped

  has_many :bottles, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  # Temps réel : la vue est groupée par cave ; on diffuse un rafraîchissement de page
  # (morphing Turbo) sur un flux dédié au module.
  broadcasts_refreshes_to ->(cellar) { [ cellar.household, "cave" ] }
end
