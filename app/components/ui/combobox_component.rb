module Ui
  class ComboboxComponent < ApplicationComponent
    def initialize(name:, options: [], selected: nil, placeholder: "Sélectionner…",
                    allow_custom: false, create_label: "Utiliser « %{query} »")
      @name = name
      @options = options
      @selected = selected
      @placeholder = placeholder
      @allow_custom = allow_custom
      @create_label = create_label
      @uid = SecureRandom.hex(4)
    end

    # When allow_custom is set, a @selected value with no matching option is a
    # previously created free-text value (e.g. a routine's list name) rather
    # than a stale/invalid id, so it's shown as-is instead of falling back to
    # the placeholder.
    def selected_label
      @options.find { |_, value| value == @selected }&.first ||
        (@selected.presence if @allow_custom) ||
        @placeholder
    end

    def listbox_id
      "combobox-#{@uid}-listbox"
    end

    def option_id(value)
      "combobox-#{@uid}-option-#{value}"
    end
  end
end
