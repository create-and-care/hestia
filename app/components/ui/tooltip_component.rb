module Ui
  class TooltipComponent < ApplicationComponent
    renders_one :trigger

    def initialize
      @panel_id = "tooltip-#{SecureRandom.hex(4)}"
    end
  end
end
