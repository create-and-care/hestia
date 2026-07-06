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
    return redirect_with(alert: t(".unknown_provider")) unless ExternalCalendarConnection::PROVIDERS.include?(provider)

    if Rails.application.credentials.dig(provider.to_sym, :client_id).present?
      # TODO (future work): redirect to the provider's OAuth consent screen
      # (or CalDAV discovery), then create the connection in #callback.
      redirect_with(alert: t(".not_implemented", provider: provider.capitalize))
    else
      redirect_with(alert: t(".not_configured", provider: provider.capitalize))
    end
  end

  def callback
    redirect_with(alert: t(".not_implemented"))
  end

  def destroy
    Current.user.external_calendar_connections.find(params[:id]).destroy
    redirect_with(notice: t(".deleted"))
  end

  private
    def redirect_with(**options)
      redirect_to external_calendar_connections_path, **options
    end
end
