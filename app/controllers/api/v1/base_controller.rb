# Socle de l'API `api/v1` (CDC §15), consommée par le client mobile Flutter.
# Authentification par jeton opaque (ApiToken) plutôt que par session cookie ;
# le scoping foyer se fait toujours côté serveur, jamais via un paramètre client.
module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_with_token!
      before_action :set_current_household

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "not_found" }, status: :not_found
      end
      rescue_from ActiveRecord::RecordInvalid do |exception|
        render json: { error: exception.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
      end

      # Pagination standardisée (CDC §15) : `?page=` et `?per_page=` (max 100, défaut 25).
      def paginate(scope)
        page = (params[:page].presence || 1).to_i
        page = 1 if page < 1

        per_page = (params[:per_page].presence || 25).to_i.clamp(1, 100)

        scope.offset((page - 1) * per_page).limit(per_page)
      end

      private
        def authenticate_with_token!
          api_token = ApiToken.authenticate(bearer_token)

          if api_token
            api_token.touch_last_used!
            Current.api_token = api_token
          else
            render json: { error: "unauthorized" }, status: :unauthorized
          end
        end

        def bearer_token
          request.headers["Authorization"].to_s[/\ABearer (.+)\z/, 1]
        end

        def set_current_household
          return if performed? # déjà répondu (401) par authenticate_with_token!

          Current.household = Current.user.households.first
          render json: { error: "no_household" }, status: :unprocessable_entity if Current.household.nil?
        end
    end
  end
end
