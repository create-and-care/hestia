module Ui
  class PopoverComponent < ApplicationComponent
    renders_one :trigger

    def initialize
      @panel_id = "popover-#{SecureRandom.hex(4)}"
    end
  end
end
