class FridgeItemsController < ApplicationController
  before_action :set_fridge_item, only: %i[edit update destroy move_to_shopping_list]

  def create
    Frigo::AddItem.call(
      household: Current.household,
      name: fridge_item_params[:name],
      location: fridge_item_params[:location],
      expires_on: fridge_item_params[:expires_on]
    )

    respond_to do |format|
      format.turbo_stream # resets the form; the item appears via the real-time stream
      format.html { redirect_to fridge_path }
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to fridge_path, alert: "Impossible d'ajouter ce produit."
  end

  def edit
  end

  def update
    if @fridge_item.update(fridge_item_params)
      redirect_to fridge_path, notice: "Produit mis à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fridge_item.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@fridge_item) }
      format.html { redirect_to fridge_path }
    end
  end

  # Fridge item → added to the shopping list (Fridge → Shopping bridge).
  def move_to_shopping_list
    Frigo::MoveToShoppingList.call(fridge_item: @fridge_item, shopping_list: target_shopping_list)
    redirect_to fridge_path, notice: "« #{@fridge_item.name} » ajouté à la liste de courses."
  end

  private
    def set_fridge_item
      @fridge_item = Current.household.fridge_items.find(params[:id])
    end

    def target_shopping_list
      Current.household.shopping_lists.order(:created_at).first ||
        Current.household.shopping_lists.create!(name: "Courses")
    end

    def fridge_item_params
      params.require(:fridge_item).permit(:name, :location, :expires_on)
    end
end
