module Ui
  class DropdownMenuComponent < ApplicationComponent
    renders_one :trigger
    # items: [["Label", "value"], :separator, ...]
    def initialize(items: [])
      @items = items
    end
  end
end
