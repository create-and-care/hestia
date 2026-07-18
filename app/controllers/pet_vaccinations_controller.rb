class PetVaccinationsController < ApplicationController
  before_action :set_pet
  before_action :set_vaccination, only: %i[edit update destroy]

  def create
    vaccination = @pet.pet_vaccinations.new(vaccination_params)
    if vaccination.save
      redirect_to @pet, notice: t(".created")
    else
      redirect_to @pet, alert: vaccination.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @vaccination.update(vaccination_params)
      redirect_to @pet, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vaccination.destroy
    redirect_to @pet, notice: t(".deleted")
  end

  private
    def set_pet
      @pet = Current.household.pets.find(params[:pet_id])
    end

    def set_vaccination
      @vaccination = @pet.pet_vaccinations.find(params[:id])
    end

    def vaccination_params
      params.require(:pet_vaccination).permit(:name, :injected_on, :booster_on, :price)
    end
end
