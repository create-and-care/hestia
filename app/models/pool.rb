class Pool < ApplicationRecord
  include HouseholdScoped

  TREATMENT_TYPES = %w[chlore sel brome oxygene_actif uv].freeze

  has_many :pool_readings, dependent: :destroy
  has_many :pool_actions, dependent: :destroy

  validates :name, presence: true
  validates :treatment_type, inclusion: { in: TREATMENT_TYPES }

  scope :ordered, -> { order(:name) }

  broadcasts_refreshes_to ->(pool) { [ pool.household, "exterior" ] }
end
