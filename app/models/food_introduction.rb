class FoodIntroduction < ApplicationRecord
  belongs_to :baby_profile

  validates :food, presence: true

  scope :recent, -> { order(introduced_on: :desc, created_at: :desc) }

  broadcasts_refreshes_to ->(introduction) { [ introduction.baby_profile.household, "baby" ] }
end
