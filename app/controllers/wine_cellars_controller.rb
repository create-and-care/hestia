class WineCellarsController < ApplicationController
  def index
    @cellars = Current.household.wine_cellars.ordered.includes(:bottles)
    @query = params[:q].to_s.strip
    if @query.present?
      @results = Current.household.bottles.where("name ILIKE ?", "%#{@query}%").includes(:wine_cellar).ordered
    end
    @cellar = Current.household.wine_cellars.new
    @bottle = Current.household.bottles.new
  end

  def create
    Current.household.wine_cellars.create(cellar_params)
    redirect_to wine_cellars_path
  end

  def destroy
    Current.household.wine_cellars.find(params[:id]).destroy
    redirect_to wine_cellars_path, notice: "Cave supprimée."
  end

  private
    def cellar_params
      params.require(:wine_cellar).permit(:name)
    end
end
