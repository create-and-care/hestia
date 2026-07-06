module Api
  module V1
    class WasteCollectionEventsController < BaseController
      def index
        events = Current.household.waste_collection_events.where(collected_on: Date.current..).ordered
        render json: paginate(events).map { |event| serialize(event) }
      end

      def create
        event = Current.household.waste_collection_events.create!(
          waste_type: params[:waste_type], collected_on: params[:collected_on]
        )
        render json: serialize(event), status: :created
      end

      private
        def serialize(event)
          event.as_json(only: %i[id waste_type collected_on waste_collection_series_id])
        end
    end
  end
end
