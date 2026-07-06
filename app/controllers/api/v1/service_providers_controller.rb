module Api
  module V1
    class ServiceProvidersController < BaseController
      def index
        providers = Current.household.service_providers.ordered
        render json: paginate(providers).map { |provider| serialize(provider) }
      end

      private
        def serialize(provider)
          provider.as_json(only: %i[id name phone email address service_provider_type_id])
        end
    end
  end
end
