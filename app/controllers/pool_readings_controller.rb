class PoolReadingsController < ApplicationController
  before_action :set_pool

  def create
    reading = @pool.pool_readings.new(reading_params)
    if reading.save
      redirect_to exterior_path
    else
      redirect_to exterior_path, alert: reading.errors.full_messages.to_sentence
    end
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
