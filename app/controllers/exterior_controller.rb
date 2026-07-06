class ExteriorController < ApplicationController
  # Household garden (plants) and pool(s) (Spec §11.3).
  def show
    @plants = Current.household.plants.ordered
    @pools = Current.household.pools.ordered.includes(:pool_readings, :pool_actions)
    @plant = Current.household.plants.new
    @pool = Current.household.pools.new
  end
end
