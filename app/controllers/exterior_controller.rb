class ExteriorController < ApplicationController
  # Household garden (plants) and pool(s).
  def show
    @plants = Current.household.plants.ordered.includes(:plant_reference, photo_attachment: :blob)
    @plant = Current.household.plants.new

    if Current.household.pool_enabled?
      @pools = Current.household.pools.ordered.includes(:pool_readings, :pool_actions, :service_provider)
      @pool = Current.household.pools.new
    end
  end
end
