# Scaffold for external calendar synchronization (Spec §9.2, §16). The actual OAuth
# Google/Microsoft (or Apple CalDAV) flow requires application credentials
# provided by the host via `bin/rails credentials:edit` (see README): without them,
# we inform the user rather than failing silently.
class ExternalCalendarConnectionsController < ApplicationController
  def index
    @connections = Current.user.external_calendar_connections
  end

  def connect
    provider = params[:provider]
    return redirect_with(alert: "Fournisseur inconnu.") unless ExternalCalendarConnection::PROVIDERS.include?(provider)

    if Rails.application.credentials.dig(provider.to_sym, :client_id).present?
      # TODO (future work): redirect to the provider's OAuth consent screen
      # (or CalDAV discovery), then create the connection in #callback.
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
