module Ui
  class PopoverComponent < ApplicationComponent
    renders_one :trigger

    def initialize(placement: "bottom-start")
      @panel_id = "popover-#{SecureRandom.hex(4)}"
      @placement = placement
    end
  end
end
