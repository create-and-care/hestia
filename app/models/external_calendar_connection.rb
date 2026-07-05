# Connexion à un calendrier externe (CDC §9.2, §16) : Google (OAuth), Microsoft
# (MSAL/OAuth) ou Apple (CalDAV). Scaffold de données uniquement à ce stade — le
# flux OAuth/CalDAV réel (Calendar::ExternalSync::*) nécessite des identifiants
# d'application (client_id/client_secret) fournis par l'hébergeur via
# `bin/rails credentials:edit`, non inclus dans ce dépôt.
#
# En production, `access_token`/`refresh_token` devraient être chiffrés au repos via
# Active Record Encryption (`encrypts`), une fois les clés de chiffrement générées
# pour l'instance (cf. README).
class ExternalCalendarConnection < ApplicationRecord
  PROVIDERS = %w[google microsoft caldav].freeze

  belongs_to :user

  validates :provider, inclusion: { in: PROVIDERS }

  scope :active, -> { where(active: true) }

  def google? = provider == "google"
  def microsoft? = provider == "microsoft"
  def caldav? = provider == "caldav"
end
