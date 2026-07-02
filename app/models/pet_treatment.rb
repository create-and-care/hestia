class PetTreatment < ApplicationRecord
  belongs_to :pet

  validates :name, presence: true

  scope :ordered, -> { order(:name) }
end
