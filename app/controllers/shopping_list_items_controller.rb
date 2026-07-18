class ShoppingListItemsController < ApplicationController
  before_action :set_shopping_list
  before_action :set_item, only: %i[update destroy toggle move_to_fridge move_up move_down]

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
    redirect_to @shopping_list, alert: t(".alert")
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
    Frigo::AddFromShoppingListItem.call(shopping_list_item: @item, expires_on: params[:expires_on].presence)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@item) }
      format.html { redirect_to @shopping_list, notice: t(".notice") }
    end
  end

  # Keyboard-accessible alternative to the drag-and-drop reorder handle —
  # swaps position with the adjacent item within the same rayon/checked
  # group (its actual visual neighbor).
  def move_up
    swap_with_sibling(-1)
    respond_with_list
  end

  def move_down
    swap_with_sibling(1)
    respond_with_list
  end

  # Bulk-clears every checked item at once ("finish the list" after a
  # shopping trip) — each destroy still broadcasts individually, keeping
  # other household members' screens in sync in real time.
  def clear_checked
    @shopping_list.items.where(checked: true).destroy_all
    respond_with_list
  end

  private
    def respond_with_list
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("shopping_list_items", partial: "shopping_list_items/list", locals: { shopping_list: @shopping_list }) }
        format.html { redirect_to @shopping_list }
      end
    end

    def swap_with_sibling(direction)
      siblings = @shopping_list.items.where(checked: @item.checked, rayon: @item.rayon).to_a
      index = siblings.index(@item)
      sibling = siblings[index + direction] if index && (index + direction).between?(0, siblings.size - 1)
      return unless sibling

      @item.position, sibling.position = sibling.position, @item.position
      @item.save!
      sibling.save!
    end

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
