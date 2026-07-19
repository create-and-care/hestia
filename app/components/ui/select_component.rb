module Ui
  class SelectComponent < ApplicationComponent
    # options: [["Label", "value"], ...]
    def initialize(name:, options: [], selected: nil, placeholder: I18n.t("ui.select.placeholder"), data: {})
      @name = name
      @options = options
      @selected = selected
      @placeholder = placeholder
      @data = data
      @uid = SecureRandom.hex(4)
    end

    def selected_label
      @options.find { |_, value| value == @selected }&.first || @placeholder
    end

    def panel_id
      "select-#{@uid}-listbox"
    end

    def option_id(value)
      "select-#{@uid}-option-#{value}"
    end
  end
end
