class FridgeController < ApplicationController
  # Shared fridge view: food items (by location) and prepared dishes,
  # with text search and expiry color coding.
  def show
    @query = params[:q].to_s.strip
    items = Current.household.fridge_items.ordered
    items = items.where("name ILIKE ?", "%#{@query}%") if @query.present?

    @fridge_items = items
    @prepared_dishes = Current.household.prepared_dishes.ordered.includes(photo_attachment: :blob)
    @fridge_item = FridgeItem.new
    @prepared_dish = PreparedDish.new
    @recipe_suggestions = Frigo::SuggestRecipes.call(household: Current.household)
  end
end
