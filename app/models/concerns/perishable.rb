# Statut de péremption d'un enregistrement portant une colonne `expires_on`.
# Calculé côté serveur à partir de la date courante (jamais figé à la création),
# pour rester correct sans action de l'utilisateur — CDC §9.4.
module Perishable
  extend ActiveSupport::Concern

  def expiration_status
    return :none if expires_on.blank?

    days_left = (expires_on - Date.current).to_i
    if days_left.negative?
      :expired
    elsif days_left <= 1
      :urgent   # dépassé aujourd'hui / demain
    elsif days_left <= 3
      :soon     # 2 à 3 jours
    else
      :ok       # au-delà
    end
  end
end
