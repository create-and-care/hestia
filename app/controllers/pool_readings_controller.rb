class PoolReadingsController < ApplicationController
  before_action :set_pool

  def create
    @pool.pool_readings.create(reading_params)
    redirect_to exterior_path
  end

  def destroy
    @pool.pool_readings.find(params[:id]).destroy
    redirect_to exterior_path
  end

  private
    def set_pool
      @pool = Current.household.pools.find(params[:pool_id])
    end

    def reading_params
      params.require(:pool_reading).permit(:measured_on, :measure_type, :value)
    end
end
