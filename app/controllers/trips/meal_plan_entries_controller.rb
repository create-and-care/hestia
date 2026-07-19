module Trips
  class MealPlanEntriesController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :set_trip

    def create
      entry = @trip.meal_plan_entries.create!(entry_params.merge(household: Current.household))
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append(dom_id(@trip, :meal_plan_entries), partial: "trips/meal_plan_entry", locals: { trip: @trip, meal_plan_entry: entry }) }
        format.html { redirect_to @trip }
      end
    rescue ActiveRecord::RecordInvalid
      redirect_to @trip, alert: t(".alert")
    end

    def destroy
      entry = @trip.meal_plan_entries.find(params[:id])
      entry.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(entry) }
        format.html { redirect_to @trip }
      end
    end

    private
      def set_trip
        @trip = Current.household.trips.find(params[:trip_id])
      end

      def entry_params
        params.require(:meal_plan_entry).permit(:on_date, :meal_type, :free_name)
      end
  end
end
