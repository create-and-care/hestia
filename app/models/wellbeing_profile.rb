class WellbeingProfile < ApplicationRecord
  # Architectural deviation: scoped by USER, never by household. No data
  # from this module is visible to other members, even administrators.
  SEXES = %w[female male other].freeze
  ACTIVITY_LEVELS = %w[sedentary light moderate active very_active].freeze

  belongs_to :user

  validates :sex, inclusion: { in: SEXES }, allow_blank: true
  validates :activity_level, inclusion: { in: ACTIVITY_LEVELS }, allow_blank: true

  def bmi(weight)
    return if height.to_i.zero? || weight.blank?

    (weight / ((height / 100.0)**2)).round(1)
  end
end
