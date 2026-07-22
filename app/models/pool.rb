class Pool < ApplicationRecord
  include HouseholdScoped

  TREATMENT_TYPES = %w[chlore sel brome oxygene_actif uv].freeze

  # Which measure_types are relevant to log depends on the pool's treatment
  # pH and temperature always matter, plus one treatment-specific
  # reading. Keeps PoolReading#measure_type from accepting an arbitrary string
  # unrelated to how this particular pool is actually treated.
  MEASURE_TYPES_BY_TREATMENT = {
    "chlore" => %w[pH temperature chlore_libre],
    "sel" => %w[pH temperature taux_sel],
    "brome" => %w[pH temperature brome],
    "oxygene_actif" => %w[pH temperature oxygene_actif],
    "uv" => %w[pH temperature]
  }.freeze

  has_many :pool_readings, dependent: :destroy
  has_many :pool_actions, dependent: :destroy
  belongs_to :service_provider, optional: true

  validates :name, presence: true
  validates :treatment_type, inclusion: { in: TREATMENT_TYPES }
  validate :service_provider_belongs_to_household

  scope :ordered, -> { order(:name) }

  broadcasts_refreshes_to ->(pool) { [ pool.household, "exterior" ] }

  def measure_types
    MEASURE_TYPES_BY_TREATMENT.fetch(treatment_type, %w[pH temperature])
  end

  private
    def service_provider_belongs_to_household
      errors.add(:service_provider, :invalid) if service_provider && service_provider.household_id != household_id
    end
end
