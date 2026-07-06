module Api
  module V1
    class NotesController < BaseController
      def index
        notes = Current.household.notes.general.ordered.active
        render json: paginate(notes).map { |note| serialize(note) }
      end

      def create
        note = Current.household.notes.create!(
          title: params[:title], content: params[:content], author: Current.user
        )
        render json: serialize(note), status: :created
      end

      private
        def serialize(note)
          note.as_json(only: %i[id title content favorite archived])
        end
    end
  end
end
