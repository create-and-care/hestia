class VehicleMaintenanceEntry < ApplicationRecord
  belongs_to :vehicle

  validates :entry_type, presence: true

  scope :chronological, -> { order(done_on: :desc, created_at: :desc) }
end
