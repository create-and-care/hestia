module Api
  module V1
    class FeedingSessionsController < BaseController
      before_action :set_baby

      def index
        render json: paginate(@baby.feeding_sessions.recent).map { |session| serialize(session) }
      end

      def create
        session = @baby.feeding_sessions.create!(
          kind: params[:kind], started_at: params[:started_at], ended_at: params[:ended_at]
        )
        render json: serialize(session), status: :created
      end

      private
        def set_baby
          @baby = Current.household.baby_profiles.find(params[:baby_profile_id])
        end

        def serialize(session)
          session.as_json(only: %i[id kind started_at ended_at baby_profile_id])
            .merge(duration_minutes: session.duration_minutes)
        end
    end
  end
end
