class PoolReading < ApplicationRecord
  belongs_to :pool

  validates :measured_on, presence: true
  validates :measure_type, presence: true
  validates :measure_type, inclusion: { in: ->(reading) { reading.pool.measure_types } }, if: -> { pool.present? }

  scope :recent, -> { order(measured_on: :desc, created_at: :desc) }

  broadcasts_refreshes_to ->(reading) { [ reading.pool.household, "exterior" ] }
end
