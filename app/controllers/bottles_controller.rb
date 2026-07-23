class BottlesController < ApplicationController
  before_action :set_bottle, only: %i[edit update toggle_stock destroy]

  def create
    cellar = Current.household.wine_cellars.find(params.dig(:bottle, :wine_cellar_id))
    bottle = cellar.bottles.new(bottle_params.merge(household: Current.household))
    if bottle.save
      redirect_to wine_cellars_path, notice: t(".created")
    else
      redirect_to wine_cellars_path, alert: bottle.errors.full_messages.to_sentence
    end
  end

  def edit
    @cellar_options = Current.household.wine_cellars.order(:name).map { |cellar| [ cellar.name, cellar.id ] }
    @regions = Current.household.bottles.where.not(region: [ nil, "" ]).distinct.order(:region).pluck(:region)
  end

  # Handles both correcting a bottle's own details (name/vintage/region/type/photo) and
  # moving it to another cellar — previously only the cellar move was possible here. The
  # target cellar is resolved through the household's own scope (like the original
  # cellar-move-only implementation) so a foreign id 404s instead of silently reassigning
  # the bottle to another household's cellar.
  def update
    attributes = bottle_params.except(:wine_cellar_id)
    if params.dig(:bottle, :wine_cellar_id).present?
      attributes[:wine_cellar] = Current.household.wine_cellars.find(params[:bottle][:wine_cellar_id])
    end

    if @bottle.update(attributes)
      redirect_to wine_cellars_path, notice: t(".updated")
    else
      @cellar_options = Current.household.wine_cellars.order(:name).map { |cellar| [ cellar.name, cellar.id ] }
      @regions = Current.household.bottles.where.not(region: [ nil, "" ]).distinct.order(:region).pluck(:region)
      render :edit, status: :unprocessable_entity
    end
  end

  # Stock entry / exit (consumption).
  def toggle_stock
    @bottle.update!(in_stock: !@bottle.in_stock)
    redirect_to wine_cellars_path
  end

  def destroy
    @bottle.destroy
    redirect_to wine_cellars_path, notice: t(".deleted")
  end

  private
    def set_bottle
      @bottle = Current.household.bottles.find(params[:id])
    end

    def bottle_params
      params.require(:bottle).permit(:name, :vintage, :region, :wine_type, :wine_cellar_id, :photo)
    end
end
