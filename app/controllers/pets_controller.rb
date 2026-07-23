class PetsController < ApplicationController
  include CollectionViewMode

  before_action :set_pet, only: %i[show edit update destroy]

  def index
    @pets = Current.household.pets.ordered.includes(photo_attachment: :blob)
    @view_mode = collection_view_mode(:pets)
  end

  def show
    @vaccination = @pet.pet_vaccinations.new
    @treatment = @pet.pet_treatments.new
    @supply = @pet.pet_supplies.new
  end

  def new
    @pet = Current.household.pets.new
    @service_providers = Current.household.service_providers.order(:name)
  end

  def create
    @pet = Current.household.pets.new(pet_params)
    if @pet.save
      redirect_to @pet, notice: t(".created")
    else
      @service_providers = Current.household.service_providers.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @service_providers = Current.household.service_providers.order(:name)
  end

  def update
    if @pet.update(pet_params)
      redirect_to @pet, notice: t(".updated")
    else
      @service_providers = Current.household.service_providers.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pet.destroy
    redirect_to pets_path, notice: t(".deleted")
  end

  private
    def set_pet
      @pet = Current.household.pets.find(params[:id])
    end

    def pet_params
      params.require(:pet).permit(:name, :species, :breed, :weight, :identifier, :born_on, :photo, :service_provider_id)
    end
end
