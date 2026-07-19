class Vehicle < ApplicationRecord
  include HouseholdScoped

  TYPES = %w[car motorcycle].freeze

  has_many :vehicle_maintenance_entries, dependent: :destroy
  has_many :documents, as: :documentable, dependent: :nullify
  has_one_attached :photo

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  broadcasts_to ->(vehicle) { vehicle.household }

  # Technical inspection color code — fixed thresholds (Spec §10.7), computed server-side.
  def inspection_status
    return :none if inspection_expires_on.blank?

    days_left = (inspection_expires_on - Date.current).to_i
    if days_left.negative?
      :expired
    elsif days_left <= 30
      :urgent
    elsif days_left <= 90
      :soon
    else
      :ok
    end
  end
end
