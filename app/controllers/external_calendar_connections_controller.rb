# Real OAuth (Google/Microsoft) and CalDAV external calendar sync
# Google/Microsoft require the host to register an OAuth application
# and configure its client_id/client_secret via `bin/rails credentials:edit`
# (see README) — until then, #connect informs the user rather than failing
# silently. CalDAV needs no such app-level credential, only the per-connection
# server URL/username/password entered directly by the user.
class ExternalCalendarConnectionsController < ApplicationController
  def index
    @connections = Current.user.external_calendar_connections
  end

  def connect
    provider = params[:provider]
    return redirect_with(alert: t(".unknown_provider")) unless ExternalCalendarConnection::PROVIDERS.include?(provider)

    if provider == "caldav"
      render :connect_caldav, locals: { provider: provider }
    elsif Calendar::ExternalSync::OauthConfig.configured?(provider)
      redirect_to_provider(provider)
    else
      redirect_with(alert: t(".not_configured", provider: provider.capitalize))
    end
  end

  def callback
    provider = params[:provider]
    return redirect_with(alert: t(".unknown_provider")) unless ExternalCalendarConnection::PROVIDERS.include?(provider)
    return redirect_with(alert: t(".state_mismatch")) if params[:state].blank? || params[:state] != session.delete(:external_calendar_oauth_state)

    tokens = Calendar::ExternalSync::OauthProvider.new(provider).exchange_code(code: params[:code], redirect_uri: callback_url(provider))
    connection = Current.user.external_calendar_connections.create!(
      provider: provider, access_token: tokens[:access_token], refresh_token: tokens[:refresh_token], expires_at: tokens[:expires_at]
    )
    Calendar::ExternalSync::SyncConnection.call(connection)
    redirect_with(notice: t(".connected", provider: provider.capitalize))
  rescue OAuth2::Error
    redirect_with(alert: t(".exchange_failed", provider: params[:provider].to_s.capitalize))
  end

  # CalDAV manual entry (no OAuth redirect flow).
  def create
    connection = Current.user.external_calendar_connections.new(
      provider: "caldav", caldav_url: caldav_params[:caldav_url],
      username: caldav_params[:username], access_token: caldav_params[:password]
    )

    if connection.save
      Calendar::ExternalSync::SyncConnection.call(connection)
      redirect_with(notice: t(".connected", provider: "CalDAV"))
    else
      redirect_with(alert: connection.errors.full_messages.to_sentence)
    end
  end

  def destroy
    Current.user.external_calendar_connections.find(params[:id]).destroy
    redirect_with(notice: t(".deleted"))
  end

  private
    def redirect_to_provider(provider)
      state = SecureRandom.hex(16)
      session[:external_calendar_oauth_state] = state
      redirect_to Calendar::ExternalSync::OauthProvider.new(provider).authorize_url(redirect_uri: callback_url(provider), state: state), allow_other_host: true
    end

    def callback_url(provider)
      callback_external_calendar_connections_url(provider: provider)
    end

    def caldav_params
      params.require(:external_calendar_connection).permit(:caldav_url, :username, :password)
    end

    def redirect_with(**options)
      redirect_to external_calendar_connections_path, **options
    end
end
