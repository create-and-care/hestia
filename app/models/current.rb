class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :household
  # Token-based API authentication: no session cookie, the user
  # comes from the token rather than the web session.
  attribute :api_token

  def user
    api_token&.user || session&.user
  end
end
