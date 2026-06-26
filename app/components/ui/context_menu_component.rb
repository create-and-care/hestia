module Ui
  class ContextMenuComponent < ApplicationComponent
    # items: [["Label", "value"], :separator, ...]
    def initialize(items: [])
      @items = items
    end
  end
end
