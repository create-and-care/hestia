class PetSuppliesController < ApplicationController
  before_action :set_pet
  before_action :set_supply, only: %i[edit update destroy add_to_shopping_list]

  def create
    supply = @pet.pet_supplies.new(supply_params)
    if supply.save
      redirect_to @pet, notice: t(".created")
    else
      redirect_to @pet, alert: supply.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @supply.update(supply_params)
      redirect_to @pet, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @supply.destroy
    redirect_to @pet, notice: t(".deleted")
  end

  # Interconnection with Shopping (Spec): a recurring supply can be exported straight to the
  # household's shopping list instead of only carrying an external order link.
  def add_to_shopping_list
    list = target_shopping_list
    Courses::AddItem.call(shopping_list: list, name: @supply.name)
    flash[:notice] = t(".notice")
    flash[:shopping_list_id] = list.id
    redirect_to @pet
  end

  private
    def set_pet
      @pet = Current.household.pets.find(params[:pet_id])
    end

    def set_supply
      @supply = @pet.pet_supplies.find(params[:id])
    end

    def supply_params
      params.require(:pet_supply).permit(:name, :order_url, :next_order_on)
    end

    def target_shopping_list
      Current.household.shopping_lists.order(:created_at).first ||
        Current.household.shopping_lists.create!(name: t("shopping_lists.default_list_name"))
    end
end
