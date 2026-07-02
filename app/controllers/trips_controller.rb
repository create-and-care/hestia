class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy]

  def index
    @trips = Current.household.trips.ordered
    @trip = Current.household.trips.new
  end

  def show
    @note = Note.new
    @task = Task.new
    @address = Address.new
    @shopping_list = ShoppingList.new
  end

  def create
    @trip = Current.household.trips.new(trip_params)
    if @trip.save
      redirect_to @trip
    else
      redirect_to trips_path, alert: @trip.errors.full_messages.to_sentence
    end
  end

  def destroy
    @trip.destroy
    redirect_to trips_path, notice: "Voyage supprimé (et toutes ses données)."
  end

  private
    def set_trip
      @trip = Current.household.trips.find(params[:id])
    end

    def trip_params
      params.require(:trip).permit(:name, :starts_on, :ends_on)
    end
end
