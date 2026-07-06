# Foundation of the `api/v1` API (Spec §15), consumed by the Flutter mobile client.
# Authentication via opaque token (ApiToken) rather than cookie session;
# household scoping always happens server-side, never via a client parameter.
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

      # Standardized pagination (Spec §15): `?page=` and `?per_page=` (max 100, default 25).
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
          return if performed? # already responded (401) by authenticate_with_token!

          Current.household = Current.user.households.first
          render json: { error: "no_household" }, status: :unprocessable_entity if Current.household.nil?
        end
    end
  end
end
