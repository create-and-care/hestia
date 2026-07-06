class WineCellar < ApplicationRecord
  include HouseholdScoped

  has_many :bottles, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  # Real-time: the view is grouped by cellar; we broadcast a page refresh
  # (Turbo morphing) on a stream dedicated to the module.
  broadcasts_refreshes_to ->(cellar) { [ cellar.household, "cave" ] }
end
