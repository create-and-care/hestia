# Patron de scoping foyer réutilisé par les modèles de la Phase 2.
# Le filtrage se fait toujours via le foyer de l'utilisateur authentifié
# (Current.household), jamais via un paramètre fourni par le client (cf. CDC §15).
module HouseholdScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :household
    scope :for_household, ->(household) { where(household: household) }
  end
end
