class AllergenTest < ApplicationRecord
  belongs_to :baby_profile

  validates :allergen, presence: true

  scope :recent, -> { order(tested_on: :desc, created_at: :desc) }
end
