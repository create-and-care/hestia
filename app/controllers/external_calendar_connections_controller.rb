# Scaffold de synchronisation calendrier externe (CDC §9.2, §16). Le flux OAuth
# Google/Microsoft (ou CalDAV Apple) réel nécessite des identifiants d'application
# fournis par l'hébergeur via `bin/rails credentials:edit` (cf. README) : sans eux,
# on informe l'utilisateur plutôt que d'échouer silencieusement.
class ExternalCalendarConnectionsController < ApplicationController
  def index
    @connections = Current.user.external_calendar_connections
  end

  def connect
    provider = params[:provider]
    return redirect_with(alert: "Fournisseur inconnu.") unless ExternalCalendarConnection::PROVIDERS.include?(provider)

    if Rails.application.credentials.dig(provider.to_sym, :client_id).present?
      # TODO (chantier ultérieur) : rediriger vers l'écran de consentement OAuth du
      # fournisseur (ou la découverte CalDAV), puis créer la connexion dans #callback.
      redirect_with(alert: "Flux de connexion #{provider.capitalize} à implémenter.")
    else
      redirect_with(alert: "Synchronisation #{provider.capitalize} non configurée sur cette instance " \
        "(identifiants d'application manquants — voir README).")
    end
  end

  def callback
    redirect_with(alert: "Flux de connexion non implémenté.")
  end

  def destroy
    Current.user.external_calendar_connections.find(params[:id]).destroy
    redirect_with(notice: "Connexion supprimée.")
  end

  private
    def redirect_with(**options)
      redirect_to external_calendar_connections_path, **options
    end
end
