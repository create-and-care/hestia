class VehicleMaintenanceEntriesController < ApplicationController
  before_action :set_vehicle

  def create
    @vehicle.vehicle_maintenance_entries.create(entry_params)
    redirect_to @vehicle
  end

  def destroy
    @vehicle.vehicle_maintenance_entries.find(params[:id]).destroy
    redirect_to @vehicle, notice: "Entrée supprimée."
  end

  private
    def set_vehicle
      @vehicle = Current.household.vehicles.find(params[:vehicle_id])
    end

    def entry_params
      params.require(:vehicle_maintenance_entry).permit(:entry_type, :done_on, :cost, :provider, :description)
    end
end
