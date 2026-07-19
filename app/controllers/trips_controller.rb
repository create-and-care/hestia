class TripsController < ApplicationController
  before_action :set_trip, only: %i[show destroy track_expenses]

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
    redirect_to trips_path, notice: t(".deleted")
  end

  # Trip -> Budget interconnection (Spec §11.4/§12.3): find-or-create the
  # trip's shared-expenses project, reusing SharedProjectsController's own
  # participant/expense/settlement UI as-is rather than duplicating it.
  def track_expenses
    project = @trip.shared_project || Current.household.shared_projects.create!(name: @trip.name, trip: @trip).tap do |new_project|
      new_project.shared_project_participants.create!(name: Current.user.name.presence || Current.user.email_address)
    end
    redirect_to project
  end

  private
    def set_trip
      @trip = Current.household.trips.find(params[:id])
    end

    def trip_params
      params.require(:trip).permit(:name, :starts_on, :ends_on)
    end
end
