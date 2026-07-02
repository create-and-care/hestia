class PetVaccination < ApplicationRecord
  belongs_to :pet

  validates :name, presence: true

  scope :ordered, -> { order(:booster_on, :injected_on) }

  def booster_overdue?
    booster_on.present? && booster_on < Date.current
  end
end
