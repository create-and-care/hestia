class VehiclesController < ApplicationController
  before_action :set_vehicle, only: %i[show edit update destroy]

  def index
    @query = params[:q].to_s.strip
    vehicles = Current.household.vehicles.ordered
    if @query.present?
      vehicles = vehicles.where("name ILIKE :q OR manufacturer ILIKE :q OR plate ILIKE :q", q: "%#{@query}%")
    end
    @vehicles = vehicles
  end

  def show
    @entry = @vehicle.vehicle_maintenance_entries.new(done_on: Date.current)
  end

  def new
    @vehicle = Current.household.vehicles.new
  end

  def create
    @vehicle = Current.household.vehicles.new(vehicle_params)
    if @vehicle.save
      redirect_to @vehicle, notice: "Véhicule ajouté."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vehicle.update(vehicle_params)
      redirect_to @vehicle, notice: "Véhicule mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vehicle.destroy
    redirect_to vehicles_path, notice: "Véhicule supprimé."
  end

  private
    def set_vehicle
      @vehicle = Current.household.vehicles.find(params[:id])
    end

    def vehicle_params
      params.require(:vehicle).permit(:name, :vehicle_type, :manufacturer, :plate, :year, :energy, :inspection_expires_on)
    end
end
