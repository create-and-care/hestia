# Management of the `api/v1` API authentication tokens (Spec §15), intended for the
# mobile client. The plaintext token is shown only once, right after it is
# created (see ApiToken).
class ApiTokensController < ApplicationController
  def index
    @tokens = Current.user.api_tokens.order(created_at: :desc)
    @token = ApiToken.new
  end

  def create
    @token = Current.user.api_tokens.create(token_params)

    if @token.persisted?
      redirect_to api_tokens_path, notice: t(".created", name: @token.name, token: @token.plaintext_token)
    else
      @tokens = Current.user.api_tokens.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    Current.user.api_tokens.find(params[:id]).destroy
    redirect_to api_tokens_path, notice: t(".revoked")
  end

  private
    def token_params
      params.require(:api_token).permit(:name)
    end
end
