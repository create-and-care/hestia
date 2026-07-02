module Trips
  class TasksController < ApplicationController
    before_action :set_trip

    def create
      @trip.tasks.create(task_params.merge(household: Current.household))
      redirect_to @trip
    end

    def destroy
      @trip.tasks.find(params[:id]).destroy
      redirect_to @trip
    end

    private
      def set_trip
        @trip = Current.household.trips.find(params[:trip_id])
      end

      def task_params
        params.require(:task).permit(:title, :emoji, :due_on)
      end
  end
end
