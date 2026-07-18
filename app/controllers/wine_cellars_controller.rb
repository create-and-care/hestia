class WineCellarsController < ApplicationController
  PER_PAGE = 10

  def index
    @query = params[:q].to_s.strip

    if @query.present?
      results = Current.household.bottles
        .where("name ILIKE :q OR region ILIKE :q OR wine_type ILIKE :q", q: "%#{@query}%")
        .includes(:wine_cellar, photo_attachment: :blob).ordered
      @results_total = results.count
      @results_total_pages = [ (@results_total / PER_PAGE.to_f).ceil, 1 ].max
      @results_page = [ [ params[:page].to_i, 1 ].max, @results_total_pages ].min
      @results = results.offset((@results_page - 1) * PER_PAGE).limit(PER_PAGE)
    else
      cellars = Current.household.wine_cellars.ordered.includes(bottles: { photo_attachment: :blob })
      @total = cellars.count
      @total_pages = [ (@total / PER_PAGE.to_f).ceil, 1 ].max
      @page = [ [ params[:page].to_i, 1 ].max, @total_pages ].min
      @cellars = cellars.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    end

    @cellar_options = Current.household.wine_cellars.order(:name).map { |cellar| [ cellar.name, cellar.id ] }
    @cellar = Current.household.wine_cellars.new
    @bottle = Current.household.bottles.new
  end

  def create
    cellar = Current.household.wine_cellars.new(cellar_params)
    if cellar.save
      redirect_to wine_cellars_path, notice: t(".created")
    else
      redirect_to wine_cellars_path, alert: cellar.errors.full_messages.to_sentence
    end
  end

  def destroy
    Current.household.wine_cellars.find(params[:id]).destroy
    redirect_to wine_cellars_path, notice: t(".deleted")
  end

  private
    def cellar_params
      params.require(:wine_cellar).permit(:name)
    end
end
