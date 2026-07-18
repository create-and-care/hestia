class AddressesController < ApplicationController
  before_action :set_address, only: %i[edit update destroy]

  PER_PAGE = 24

  def index
    @query = params[:q].to_s.strip
    @type = params[:address_type].presence
    addresses = Current.household.addresses.general.ordered.includes(photo_attachment: :blob)
    addresses = addresses.where(address_type: @type) if @type
    addresses = addresses.where("name ILIKE :q OR full_address ILIKE :q", q: "%#{@query}%") if @query.present?

    @total = addresses.count
    @total_pages = [ (@total / PER_PAGE.to_f).ceil, 1 ].max
    @page = [ [ params[:page].to_i, 1 ].max, @total_pages ].min
    @addresses = addresses.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def new
    @address = Current.household.addresses.new
  end

  # Online search to pre-fill the form (Spec §10.3, §16) — manual entry
  # always remains possible for addresses that are intentionally kept confidential.
  def search
    render json: Geocoding::SearchAddress.call(query: params[:q])
  end

  def create
    @address = Current.household.addresses.new(address_params)
    if @address.save
      redirect_to addresses_path, notice: t(".created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to addresses_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to addresses_path, notice: t(".deleted")
  end

  private
    def set_address
      @address = Current.household.addresses.find(params[:id])
    end

    def address_params
      params.require(:address).permit(:address_type, :name, :full_address, :latitude, :longitude, :phone, :rating, :photo)
    end
end
