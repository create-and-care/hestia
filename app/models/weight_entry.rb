class WeightEntry < ApplicationRecord
  belongs_to :user

  validates :recorded_on, presence: true
  validates :weight, presence: true

  scope :chronological, -> { order(:recorded_on) }
end
