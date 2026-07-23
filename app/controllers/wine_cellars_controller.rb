class WineCellarsController < ApplicationController
  PER_PAGE = 10

  def index
    @query = params[:q].to_s.strip
    @wine_cellar_id = params[:wine_cellar_id].presence
    @wine_type = params[:wine_type].presence
    @region = params[:region].presence
    @vintage = params[:vintage].presence
    @in_stock = params[:in_stock].presence
    @filtering = @wine_cellar_id || @wine_type || @region || @vintage || @in_stock

    if @query.present? || @filtering
      results = Current.household.bottles.includes(:wine_cellar, photo_attachment: :blob).ordered
      results = results.where("name ILIKE :q OR region ILIKE :q OR wine_type ILIKE :q", q: "%#{@query}%") if @query.present?
      results = results.where(wine_cellar_id: @wine_cellar_id) if @wine_cellar_id
      results = results.where(wine_type: @wine_type) if @wine_type
      results = results.where(region: @region) if @region
      results = results.where(vintage: @vintage) if @vintage
      results = results.where(in_stock: @in_stock == "1") if @in_stock
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
    @regions = Current.household.bottles.where.not(region: [ nil, "" ]).distinct.order(:region).pluck(:region)
    @vintages = Current.household.bottles.where.not(vintage: nil).distinct.order(vintage: :desc).pluck(:vintage)
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
