module Reminders
  class DailyDigestJob < ApplicationJob
    queue_as :default

    def perform = Reminders::DailyDigest.call
  end
end
