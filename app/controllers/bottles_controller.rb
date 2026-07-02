class BottlesController < ApplicationController
  before_action :set_bottle, only: %i[update toggle_stock destroy]

  def create
    cellar = Current.household.wine_cellars.find(params.dig(:bottle, :wine_cellar_id))
    cellar.bottles.create(bottle_params.merge(household: Current.household))
    redirect_to wine_cellars_path
  end

  # Déplacement d'une bouteille d'une cave à l'autre.
  def update
    if params.dig(:bottle, :wine_cellar_id).present?
      cellar = Current.household.wine_cellars.find(params[:bottle][:wine_cellar_id])
      @bottle.update(wine_cellar: cellar)
    end
    redirect_to wine_cellars_path
  end

  # Entrée / sortie (consommation) du stock.
  def toggle_stock
    @bottle.update!(in_stock: !@bottle.in_stock)
    redirect_to wine_cellars_path
  end

  def destroy
    @bottle.destroy
    redirect_to wine_cellars_path, notice: "Bouteille supprimée."
  end

  private
    def set_bottle
      @bottle = Current.household.bottles.find(params[:id])
    end

    def bottle_params
      params.require(:bottle).permit(:name, :vintage, :region, :wine_type)
    end
end
