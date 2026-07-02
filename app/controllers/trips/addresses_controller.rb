module Trips
  class AddressesController < ApplicationController
    before_action :set_trip

    def create
      @trip.addresses.create(address_params.merge(household: Current.household))
      redirect_to @trip
    end

    def destroy
      @trip.addresses.find(params[:id]).destroy
      redirect_to @trip
    end

    private
      def set_trip
        @trip = Current.household.trips.find(params[:trip_id])
      end

      def address_params
        params.require(:address).permit(:name, :address_type, :full_address, :phone)
      end
  end
end
