class PoolActionsController < ApplicationController
  before_action :set_pool

  def create
    @pool.pool_actions.create(action_params)
    redirect_to exterior_path
  end

  def destroy
    @pool.pool_actions.find(params[:id]).destroy
    redirect_to exterior_path
  end

  private
    def set_pool
      @pool = Current.household.pools.find(params[:pool_id])
    end

    def action_params
      params.require(:pool_action).permit(:done_on, :action_type, :note)
    end
end
