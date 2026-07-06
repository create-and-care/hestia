module Api
  module V1
    class AddressesController < BaseController
      def index
        addresses = Current.household.addresses.general.ordered
        render json: paginate(addresses).map { |address| serialize(address) }
      end

      private
        def serialize(address)
          address.as_json(only: %i[id address_type name full_address latitude longitude phone rating])
        end
    end
  end
end
