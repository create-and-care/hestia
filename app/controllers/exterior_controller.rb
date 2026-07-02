class ExteriorController < ApplicationController
  # Jardin (plantes) et piscine(s) du foyer (CDC §11.3).
  def show
    @plants = Current.household.plants.ordered
    @pools = Current.household.pools.ordered.includes(:pool_readings, :pool_actions)
    @plant = Current.household.plants.new
    @pool = Current.household.pools.new
  end
end
