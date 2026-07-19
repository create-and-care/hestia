module Trips
  class AddressesController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :set_trip
    before_action :set_address, only: %i[edit update destroy]

    def create
      address = @trip.addresses.create!(address_params.merge(household: Current.household))
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append(dom_id(@trip, :addresses), partial: "trips/address", locals: { trip: @trip, address: address }) }
        format.html { redirect_to @trip }
      end
    rescue ActiveRecord::RecordInvalid
      redirect_to @trip, alert: t(".alert")
    end

    def edit
    end

    def update
      if @address.update(address_params)
        redirect_to @trip, notice: t(".updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @address.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@address) }
        format.html { redirect_to @trip }
      end
    end

    private
      def set_trip
        @trip = Current.household.trips.find(params[:trip_id])
      end

      def set_address
        @address = @trip.addresses.find(params[:id])
      end

      def address_params
        params.require(:address).permit(:name, :address_type, :full_address, :phone)
      end
  end
end
