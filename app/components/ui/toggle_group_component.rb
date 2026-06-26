module Ui
  class ToggleGroupComponent < ApplicationComponent
    # items: [["Label", "value", pressed?], ...]
    def initialize(items: [], multiple: false, name: nil)
      @items = items
      @multiple = multiple
      @name = name
    end
  end
end
