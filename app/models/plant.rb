class Plant < ApplicationRecord
  include HouseholdScoped

  belongs_to :plant_reference, optional: true
  has_one_attached :photo
  has_many :plant_care_tasks, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(:name) }

  broadcasts_refreshes_to ->(plant) { [ plant.household, "exterior" ] }

  # Worst-of status across every care task, driving the badge shown on the Exterior
  # page (mirrors Vehicle#inspection_status / Perishable#expiration_status).
  def care_status
    return :none if plant_care_tasks.empty?
    return :overdue if plant_care_tasks.any?(&:overdue?)
    return :soon if plant_care_tasks.any?(&:due_soon?)

    :ok
  end
end
