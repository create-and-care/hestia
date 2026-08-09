class Vehicle < ApplicationRecord
  include HouseholdScoped

  TYPES = %w[car motorcycle scooter bicycle van truck camper boat trailer other].freeze

  has_many :vehicle_maintenance_entries, dependent: :destroy
  has_many :documents, as: :documentable, dependent: :nullify
  has_one_attached :photo

  validates :name, presence: true

  # Thresholds for #inspection_status, named so the scope below and the method
  # cannot drift apart — the dashboard asks the database the same question the
  # badge answers in Ruby.
  INSPECTION_URGENT_DAYS = 30
  INSPECTION_SOON_DAYS = 90

  scope :ordered, -> { order(:name) }
  # :expired or :destructive, decided in SQL. The dashboard used to load every
  # vehicle of the household and #select in Ruby.
  scope :inspection_due, -> {
    where(inspection_expires_on: ..(Date.current + INSPECTION_URGENT_DAYS)).order(:inspection_expires_on)
  }

  broadcasts_to ->(vehicle) { vehicle.household }

  # Technical inspection color code — fixed thresholds, computed server-side.
  def inspection_status
    return :none if inspection_expires_on.blank?

    days_left = (inspection_expires_on - Date.current).to_i
    if days_left.negative?
      :expired
    elsif days_left <= INSPECTION_URGENT_DAYS
      :destructive
    elsif days_left <= INSPECTION_SOON_DAYS
      :soon
    else
      :ok
    end
  end
end
