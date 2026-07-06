module Calendar
  module ExternalSync
    # Periodic sync of every active external calendar connection (Spec §9.2,
    # §16). See config/recurring.yml. Each connection is synced independently
    # so one failure (e.g. a revoked token) doesn't block the others.
    class SyncAllJob < ApplicationJob
      queue_as :default

      def perform
        ExternalCalendarConnection.active.find_each do |connection|
          SyncConnection.call(connection)
        end
      end
    end
  end
end
