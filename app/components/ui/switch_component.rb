module Ui
  class SwitchComponent < ApplicationComponent
    def initialize(name: nil, checked: false, disabled: false, id: nil, html_options: {})
      @name = name
      @checked = checked
      @disabled = disabled
      @id = id || "switch-#{SecureRandom.hex(4)}"
      @html_options = html_options
    end

    def call
      tag.label for: @id, class: "relative inline-flex h-5 w-9 cursor-pointer items-center" do
        tag.input(
          type: "checkbox", role: "switch", name: @name, id: @id, checked: @checked, disabled: @disabled,
          class: "peer sr-only", **@html_options
        ) +
        tag.span(class: "absolute inset-0 rounded-full bg-toggle-track transition-colors peer-checked:bg-button-primary peer-focus-visible:ring-focus peer-disabled:opacity-50") +
        tag.span(class: "absolute left-0.5 size-4 rounded-full bg-container shadow-xs transition-transform peer-checked:translate-x-4")
      end
    end
  end
end
