class WellbeingProfile < ApplicationRecord
  # Écart d'architecture : scopé par UTILISATEUR, jamais par foyer. Aucune donnée de
  # ce module n'est visible par les autres membres, même administrateurs (CDC §5, point 4).
  SEXES = %w[female male other].freeze
  ACTIVITY_LEVELS = %w[sedentary light moderate active very_active].freeze

  belongs_to :user

  def bmi(weight)
    return if height.to_i.zero? || weight.blank?

    (weight / ((height / 100.0)**2)).round(1)
  end
end
