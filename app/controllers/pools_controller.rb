class PoolsController < ApplicationController
  PER_PAGE = 10

  before_action :set_pool, only: %i[edit update destroy history]

  def create
    pool = Current.household.pools.new(pool_params)
    if pool.save
      redirect_to exterior_path
    else
      redirect_to exterior_path, alert: pool.errors.full_messages.to_sentence
    end
  end

  def edit
    @service_providers = Current.household.service_providers.order(:name)
  end

  def update
    if @pool.update(pool_params)
      redirect_to exterior_path, notice: t(".updated")
    else
      @service_providers = Current.household.service_providers.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pool.destroy
    redirect_to exterior_path, notice: t(".deleted")
  end

  # Full, paginated reading/action history (Spec §11.3), replacing the
  # hardcoded first(5) on the main Outdoor page. Also groups all readings by
  # measure_type (unpaginated) to feed a trend chart per measured quantity.
  def history
    @readings_by_type = @pool.pool_readings.order(:measured_on).group_by(&:measure_type)

    @readings_total = @pool.pool_readings.count
    @readings_total_pages = [ (@readings_total / PER_PAGE.to_f).ceil, 1 ].max
    @readings_page = [ [ params[:readings_page].to_i, 1 ].max, @readings_total_pages ].min
    @readings = @pool.pool_readings.recent.offset((@readings_page - 1) * PER_PAGE).limit(PER_PAGE)

    @actions_total = @pool.pool_actions.count
    @actions_total_pages = [ (@actions_total / PER_PAGE.to_f).ceil, 1 ].max
    @actions_page = [ [ params[:actions_page].to_i, 1 ].max, @actions_total_pages ].min
    @actions = @pool.pool_actions.recent.offset((@actions_page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  private
    def set_pool
      @pool = Current.household.pools.find(params[:id])
    end

    def pool_params
      params.require(:pool).permit(:name, :treatment_type, :service_provider_id)
    end
end
