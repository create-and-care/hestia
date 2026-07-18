class VehicleMaintenanceEntry < ApplicationRecord
  belongs_to :vehicle
  belongs_to :service_provider, optional: true

  # Predefined entry types (Spec: "type prédéfini ou libre") — the column itself stays a plain
  # string so "other" can carry any free text the household needs, not just this list.
  TYPES = %w[oil_change tires brake_pads inspection service_check other].freeze

  validates :entry_type, presence: true
  validate :service_provider_belongs_to_vehicle_household

  scope :chronological, -> { order(done_on: :desc, created_at: :desc) }

  # Real-time: mirrors the Vehicle model's own broadcasts_to so maintenance history stays in
  # sync across household members without a reload, consistent with the rest of the module.
  broadcasts_to :vehicle

  private
    def service_provider_belongs_to_vehicle_household
      return unless service_provider

      errors.add(:service_provider, :invalid) if service_provider.household_id != vehicle.household_id
    end
end
