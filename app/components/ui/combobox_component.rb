module Ui
  class ComboboxComponent < ApplicationComponent
    def initialize(name:, options: [], selected: nil, placeholder: "Select an option")
      @name = name
      @options = options
      @selected = selected
      @placeholder = placeholder
      @uid = SecureRandom.hex(4)
    end

    def selected_label
      @options.find { |_, value| value == @selected }&.first || @placeholder
    end

    def listbox_id
      "combobox-#{@uid}-listbox"
    end

    def option_id(value)
      "combobox-#{@uid}-option-#{value}"
    end
  end
end
