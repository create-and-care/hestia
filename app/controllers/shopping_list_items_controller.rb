class ShoppingListItemsController < ApplicationController
  before_action :set_shopping_list
  before_action :set_item, only: %i[update destroy toggle move_to_fridge]

  def create
    Courses::AddItem.call(
      shopping_list: @shopping_list,
      name: item_params[:name],
      quantity: item_params[:quantity],
      unit: item_params[:unit],
      rayon: item_params[:rayon]
    )

    respond_to do |format|
      format.turbo_stream # resets the form; the item appears via the real-time stream
      format.html { redirect_to @shopping_list }
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to @shopping_list, alert: "Impossible d'ajouter l'article."
  end

  def update
    @item.update(item_params)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@item) }
      format.html { redirect_to @shopping_list }
    end
  end

  def toggle
    Courses::ToggleItem.call(item: @item)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@item) }
      format.html { redirect_to @shopping_list }
    end
  end

  def destroy
    @item.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@item) }
      format.html { redirect_to @shopping_list }
    end
  end

  # Drag-and-drop reordering: applies the order of the received ids.
  def reorder
    Reordering.apply(@shopping_list.items, params[:ids])
    head :no_content
  end

  # Purchased item → stored in the fridge then removed from the list (Shopping → Fridge bridge).
  def move_to_fridge
    Frigo::AddFromShoppingListItem.call(shopping_list_item: @item)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@item) }
      format.html { redirect_to @shopping_list, notice: "Rangé au frigo." }
    end
  end

  private
    def set_shopping_list
      @shopping_list = Current.household.shopping_lists.find(params[:shopping_list_id])
    end

    def set_item
      @item = @shopping_list.items.find(params[:id])
    end

    def item_params
      params.require(:shopping_list_item).permit(:name, :quantity, :unit, :rayon)
    end
end
