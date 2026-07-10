module Ui
  class CollapsibleComponent < ApplicationComponent
    renders_one :trigger

    def initialize(id: nil)
      @id = id || "collapsible-#{SecureRandom.hex(4)}"
    end

    def panel_id
      "#{@id}-panel"
    end
  end
end
