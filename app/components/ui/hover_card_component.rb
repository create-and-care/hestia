module Ui
  class HoverCardComponent < ApplicationComponent
    renders_one :trigger

    def initialize(id: nil)
      @id = id || "hover-card-#{SecureRandom.hex(4)}"
    end

    def panel_id
      "#{@id}-panel"
    end
  end
end
