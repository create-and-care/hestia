module Ui
  class CollapsibleComponent < ApplicationComponent
    renders_one :trigger

    def initialize(id: nil, open: false)
      @id = id || "collapsible-#{SecureRandom.hex(4)}"
      @open = open
    end

    def panel_id
      "#{@id}-panel"
    end
  end
end
