class PetTreatmentsController < ApplicationController
  before_action :set_pet
  before_action :set_treatment, only: %i[edit update destroy]

  def create
    treatment = @pet.pet_treatments.new(treatment_params)
    if treatment.save
      redirect_to @pet, notice: t(".created")
    else
      redirect_to @pet, alert: treatment.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @treatment.update(treatment_params)
      redirect_to @pet, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @treatment.destroy
    redirect_to @pet, notice: t(".deleted")
  end

  private
    def set_pet
      @pet = Current.household.pets.find(params[:pet_id])
    end

    def set_treatment
      @treatment = @pet.pet_treatments.find(params[:id])
    end

    def treatment_params
      params.require(:pet_treatment).permit(:name, :frequency, :quantity, :last_done_on, :price)
    end
end
