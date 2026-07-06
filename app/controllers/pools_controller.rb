class PoolsController < ApplicationController
  def create
    Current.household.pools.create(pool_params)
    redirect_to exterior_path
  end

  def destroy
    Current.household.pools.find(params[:id]).destroy
    redirect_to exterior_path, notice: t(".deleted")
  end

  private
    def pool_params
      params.require(:pool).permit(:name, :treatment_type)
    end
end
