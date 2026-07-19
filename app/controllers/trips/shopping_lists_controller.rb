module Trips
  class ShoppingListsController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :set_trip

    def create
      list = @trip.shopping_lists.create!(list_params.merge(household: Current.household))
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append(dom_id(@trip, :shopping_lists), partial: "trips/shopping_list", locals: { trip: @trip, list: list }) }
        format.html { redirect_to @trip }
      end
    rescue ActiveRecord::RecordInvalid
      redirect_to @trip, alert: t(".alert")
    end

    def destroy
      list = @trip.shopping_lists.find(params[:id])
      list.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(list) }
        format.html { redirect_to @trip }
      end
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
