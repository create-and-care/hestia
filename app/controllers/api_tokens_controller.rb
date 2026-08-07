# Management of the `api/v1` API authentication tokens, intended for the
# mobile client. The plaintext token is shown only once, right after it is
# created (see ApiToken).
class ApiTokensController < ApplicationController
  # Fixed menu of choices rather than an arbitrary date input, mirroring how
  # GitHub/GitLab present personal access token expirations. There is
  # deliberately no never-expires choice: a perpetual bearer token that is
  # only ever shown once cannot be audited afterwards. Tokens created before
  # this restriction keep their NULL expires_at and stay valid (see
  # ApiToken.active) — the choice is removed going forward, not retroactively.
  EXPIRATION_CHOICES = { "30" => 30.days, "90" => 90.days, "365" => 365.days }.freeze
  DEFAULT_EXPIRATION = "90"

  def create
    token = Current.user.api_tokens.new(token_params.merge(expires_at: expires_at_from_params))

    if token.save
      flash[:api_token] = token.plaintext_token
      redirect_to household_path(Current.household, tab: "api"), notice: t(".created", name: token.name)
    else
      redirect_to household_path(Current.household, tab: "api"), alert: token.errors.full_messages.to_sentence
    end
  end

  def destroy
    Current.user.api_tokens.find(params[:id]).destroy
    redirect_to household_path(Current.household, tab: "api"), notice: t(".revoked")
  end

  private
    def token_params
      params.require(:api_token).permit(:name)
    end

    # Falls back to the default rather than to nil, so an unrecognised
    # expires_in — a hand-crafted POST, or a stale form — cannot mint the
    # perpetual token the <select> no longer offers.
    def expires_at_from_params
      duration = EXPIRATION_CHOICES.fetch(params[:api_token][:expires_in].to_s) { EXPIRATION_CHOICES.fetch(DEFAULT_EXPIRATION) }
      Time.current + duration
    end
end
