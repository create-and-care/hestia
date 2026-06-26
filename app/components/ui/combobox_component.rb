module Ui
  class ComboboxComponent < ApplicationComponent
    def initialize(name:, options: [], selected: nil, placeholder: "Select an option")
      @name = name
      @options = options
      @selected = selected
      @placeholder = placeholder
    end

    def selected_label
      @options.find { |_, value| value == @selected }&.first || @placeholder
    end
  end
end
