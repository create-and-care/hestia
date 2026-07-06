class PreparedDishesController < ApplicationController
  def create
    Current.household.prepared_dishes.create!(prepared_dish_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to fridge_path }
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to fridge_path, alert: t(".alert")
  end

  def destroy
    dish = Current.household.prepared_dishes.find(params[:id])
    dish.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dish) }
      format.html { redirect_to fridge_path }
    end
  end

  private
    def prepared_dish_params
      params.require(:prepared_dish).permit(:name, :location, :expires_on)
    end
end
