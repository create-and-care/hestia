module Ui
  class RadioGroupComponent < ApplicationComponent
    # options: [["Label", "value"], ...]
    def initialize(name:, options: [], selected: nil)
      @name = name
      @options = options
      @selected = selected
    end
  end
end
