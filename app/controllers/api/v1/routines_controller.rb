module Api
  module V1
    class RoutinesController < BaseController
      def index
        render json: paginate(Current.household.routines.ordered).map { |routine| serialize(routine) }
      end

      def complete
        routine = Current.household.routines.find(params[:id])
        routine.complete!(author: Current.user)
        render json: serialize(routine)
      end

      private
        def serialize(routine)
          routine.as_json(only: %i[id name emoji description frequency interval list_name next_due_on assignee_id])
        end
    end
  end
end
