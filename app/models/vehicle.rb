class Vehicle < ApplicationRecord
  include HouseholdScoped

  TYPES = %w[car motorcycle].freeze

  has_many :vehicle_maintenance_entries, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  broadcasts_to ->(vehicle) { vehicle.household }

  # Code couleur du contrôle technique — seuils fixes (CDC §10.7), calculé côté serveur.
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
