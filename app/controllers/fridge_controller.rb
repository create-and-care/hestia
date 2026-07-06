class FridgeController < ApplicationController
  # Shared fridge view: food items (by location) and prepared dishes,
  # with text search and expiry color coding (Spec §9.4).
  def show
    @query = params[:q].to_s.strip
    items = Current.household.fridge_items.ordered
    items = items.where("name ILIKE ?", "%#{@query}%") if @query.present?

    @fridge_items = items
    @prepared_dishes = Current.household.prepared_dishes.ordered
    @fridge_item = FridgeItem.new
    @prepared_dish = PreparedDish.new
  end
end
