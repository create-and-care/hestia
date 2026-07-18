class VehicleMaintenanceEntriesController < ApplicationController
  before_action :set_vehicle

  def create
    entry = @vehicle.vehicle_maintenance_entries.new(entry_params)
    if entry.save
      redirect_to @vehicle, notice: t(".created")
    else
      redirect_to @vehicle, alert: entry.errors.full_messages.to_sentence
    end
  end

  def destroy
    @vehicle.vehicle_maintenance_entries.find(params[:id]).destroy
    redirect_to @vehicle, notice: t(".deleted")
  end

  private
    def set_vehicle
      @vehicle = Current.household.vehicles.find(params[:vehicle_id])
    end

    def entry_params
      params.require(:vehicle_maintenance_entry).permit(:entry_type, :done_on, :cost, :provider, :description, :service_provider_id)
    end
end
