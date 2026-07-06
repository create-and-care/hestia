class PetTreatmentsController < ApplicationController
  before_action :set_pet

  def create
    @pet.pet_treatments.create(treatment_params)
    redirect_to @pet
  end

  def destroy
    @pet.pet_treatments.find(params[:id]).destroy
    redirect_to @pet, notice: t(".deleted")
  end

  private
    def set_pet
      @pet = Current.household.pets.find(params[:pet_id])
    end

    def treatment_params
      params.require(:pet_treatment).permit(:name, :frequency, :quantity, :last_done_on, :price)
    end
end
