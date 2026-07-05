class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :household
  # Authentification API par jeton (CDC §15) : pas de session cookie, l'utilisateur
  # vient du jeton plutôt que de la session web.
  attribute :api_token

  def user
    api_token&.user || session&.user
  end
end
