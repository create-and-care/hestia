module Trips
  class NotesController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :set_trip
    before_action :set_note, only: %i[edit update destroy]

    def create
      note = @trip.notes.create!(note_params.merge(household: Current.household, author: Current.user))
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append(dom_id(@trip, :notes), partial: "trips/note", locals: { trip: @trip, note: note }) }
        format.html { redirect_to @trip }
      end
    rescue ActiveRecord::RecordInvalid
      redirect_to @trip, alert: t(".alert")
    end

    def edit
    end

    def update
      if @note.update(note_params)
        redirect_to @trip, notice: t(".updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @note.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@note) }
        format.html { redirect_to @trip }
      end
    end

    private
      def set_trip
        @trip = Current.household.trips.find(params[:trip_id])
      end

      def set_note
        @note = @trip.notes.find(params[:id])
      end

      def note_params
        params.require(:note).permit(:title, :content)
      end
  end
end
