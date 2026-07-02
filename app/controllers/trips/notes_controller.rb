module Trips
  class NotesController < ApplicationController
    before_action :set_trip

    def create
      @trip.notes.create(note_params.merge(household: Current.household, author: Current.user))
      redirect_to @trip
    end

    def destroy
      @trip.notes.find(params[:id]).destroy
      redirect_to @trip
    end

    private
      def set_trip
        @trip = Current.household.trips.find(params[:trip_id])
      end

      def note_params
        params.require(:note).permit(:title, :content)
      end
  end
end
