class ServiceProviderTypesController < ApplicationController
  def create
    Current.household.service_provider_types.create(type_params)
    redirect_to service_providers_path
  end

  def destroy
    Current.household.service_provider_types.find(params[:id]).destroy
    redirect_to service_providers_path, notice: "Type supprimé."
  end

  private
    def type_params
      params.require(:service_provider_type).permit(:name, :icon, :color)
    end
end
