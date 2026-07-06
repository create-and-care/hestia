class ServiceProvidersController < ApplicationController
  before_action :set_provider, only: %i[edit update destroy]

  def index
    @query = params[:q].to_s.strip
    @type = Current.household.service_provider_types.find_by(id: params[:type_id]) if params[:type_id].present?
    @types = Current.household.service_provider_types.order(:name)

    providers = Current.household.service_providers.ordered.includes(:service_provider_type)
    providers = providers.where(service_provider_type_id: @type.id) if @type
    providers = providers.where("name ILIKE ?", "%#{@query}%") if @query.present?
    @providers = providers
  end

  def new
    @provider = Current.household.service_providers.new
  end

  def create
    @provider = Current.household.service_providers.new(provider_params)
    if @provider.save
      redirect_to service_providers_path, notice: t(".created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @provider.update(provider_params)
      redirect_to service_providers_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @provider.destroy
    redirect_to service_providers_path, notice: t(".deleted")
  end

  private
    def set_provider
      @provider = Current.household.service_providers.find(params[:id])
    end

    def provider_params
      permitted = params.require(:service_provider).permit(:name, :phone, :email, :address, :service_provider_type_id)
      permitted[:service_provider_type_id] = nil unless valid_type_id?(permitted[:service_provider_type_id])
      permitted
    end

    def valid_type_id?(id)
      id.blank? || Current.household.service_provider_types.exists?(id: id)
    end
end
