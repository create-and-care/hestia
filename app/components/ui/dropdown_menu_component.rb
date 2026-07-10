module Ui
  class DropdownMenuComponent < ApplicationComponent
    renders_one :trigger
    # items: [["Label", "value"], :separator, ...]
    def initialize(items: [])
      @items = items
      @panel_id = "dropdown-menu-#{SecureRandom.hex(4)}"
    end
  end
end
