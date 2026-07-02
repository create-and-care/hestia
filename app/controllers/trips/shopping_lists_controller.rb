module Trips
  class ShoppingListsController < ApplicationController
    before_action :set_trip

    def create
      @trip.shopping_lists.create(list_params.merge(household: Current.household))
      redirect_to @trip
    end

    def destroy
      @trip.shopping_lists.find(params[:id]).destroy
      redirect_to @trip
    end

    private
      def set_trip
        @trip = Current.household.trips.find(params[:trip_id])
      end

      def list_params
        params.require(:shopping_list).permit(:name, :icon)
      end
  end
end
