class PlantCareCompletion < ApplicationRecord
  belongs_to :plant_care_task
  belongs_to :author, class_name: "User", optional: true

  validates :completed_on, presence: true

  scope :recent, -> { order(completed_on: :desc) }
end
