class PetVaccinationsController < ApplicationController
  before_action :set_pet

  def create
    @pet.pet_vaccinations.create(vaccination_params)
    redirect_to @pet
  end

  def destroy
    @pet.pet_vaccinations.find(params[:id]).destroy
    redirect_to @pet, notice: "Vaccin supprimé."
  end

  private
    def set_pet
      @pet = Current.household.pets.find(params[:pet_id])
    end

    def vaccination_params
      params.require(:pet_vaccination).permit(:name, :injected_on, :booster_on, :price)
    end
end
