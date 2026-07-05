class AddressesController < ApplicationController
  before_action :set_address, only: %i[edit update destroy]

  def index
    @query = params[:q].to_s.strip
    @type = params[:address_type].presence
    addresses = Current.household.addresses.general.ordered
    addresses = addresses.where(address_type: @type) if @type
    addresses = addresses.where("name ILIKE :q OR full_address ILIKE :q", q: "%#{@query}%") if @query.present?
    @addresses = addresses
  end

  def new
    @address = Current.household.addresses.new
  end

  # Recherche en ligne pour pré-remplir la fiche (CDC §10.3, §16) — la saisie
  # manuelle reste toujours possible pour les adresses volontairement confidentielles.
  def search
    render json: Geocoding::SearchAddress.call(query: params[:q])
  end

  def create
    @address = Current.household.addresses.new(address_params)
    if @address.save
      redirect_to addresses_path, notice: "Adresse ajoutée."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to addresses_path, notice: "Adresse mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to addresses_path, notice: "Adresse supprimée."
  end

  private
    def set_address
      @address = Current.household.addresses.find(params[:id])
    end

    def address_params
      params.require(:address).permit(:address_type, :name, :full_address, :latitude, :longitude, :phone, :rating)
    end
end
