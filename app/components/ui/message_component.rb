module Ui
  # A full conversation row: avatar + Bubble + timestamp, aligned by role.
  # Several stack inside Ui::MessageScrollerComponent to form a thread.
  class MessageComponent < ApplicationComponent
    def initialize(role: :assistant, name: nil, timestamp: nil)
      @role = role
      @name = name || (role == :user ? "Vous" : "Assistant")
      @timestamp = timestamp
    end
  end
end
