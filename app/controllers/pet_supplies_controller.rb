class PetSuppliesController < ApplicationController
  before_action :set_pet

  def create
    @pet.pet_supplies.create(supply_params)
    redirect_to @pet
  end

  def destroy
    @pet.pet_supplies.find(params[:id]).destroy
    redirect_to @pet, notice: "Produit supprimé."
  end

  private
    def set_pet
      @pet = Current.household.pets.find(params[:pet_id])
    end

    def supply_params
      params.require(:pet_supply).permit(:name, :order_url, :next_order_on)
    end
end
