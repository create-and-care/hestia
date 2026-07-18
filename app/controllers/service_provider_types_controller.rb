class ServiceProviderTypesController < ApplicationController
  before_action :set_type, only: %i[edit update destroy]

  def create
    type = Current.household.service_provider_types.new(type_params)
    if type.save
      redirect_to service_providers_path, notice: t(".created")
    else
      redirect_to service_providers_path, alert: type.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @type.update(type_params)
      redirect_to service_providers_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @type.destroy
    redirect_to service_providers_path, notice: t(".deleted")
  end

  private
    def set_type
      @type = Current.household.service_provider_types.find(params[:id])
    end

    def type_params
      params.require(:service_provider_type).permit(:name, :icon, :color)
    end
end
