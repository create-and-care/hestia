# Gestion des jetons d'authentification de l'API `api/v1` (CDC §15), destinés au
# client mobile. Le jeton en clair n'est affiché qu'une seule fois, juste après sa
# création (cf. ApiToken).
class ApiTokensController < ApplicationController
  def index
    @tokens = Current.user.api_tokens.order(created_at: :desc)
    @token = ApiToken.new
  end

  def create
    @token = Current.user.api_tokens.create(token_params)

    if @token.persisted?
      redirect_to api_tokens_path, notice: "Jeton « #{@token.name} » créé : #{@token.plaintext_token} (copiez-le, il ne sera plus affiché)."
    else
      @tokens = Current.user.api_tokens.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    Current.user.api_tokens.find(params[:id]).destroy
    redirect_to api_tokens_path, notice: "Jeton révoqué."
  end

  private
    def token_params
      params.require(:api_token).permit(:name)
    end
end
