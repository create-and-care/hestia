module Reminders
  class DeliverDueJob < ApplicationJob
    queue_as :default

    def perform = Reminders::DeliverDue.call
  end
end
