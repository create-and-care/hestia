module Ui
  class CheckboxComponent < ApplicationComponent
    def initialize(name: nil, checked: false, disabled: false, id: nil, html_options: {})
      @name = name
      @checked = checked
      @disabled = disabled
      @id = id || "checkbox-#{SecureRandom.hex(4)}"
      @html_options = html_options
    end

    def call
      tag.span class: "relative inline-flex size-[var(--control-box)]" do
        tag.input(
          type: "checkbox", name: @name, id: @id, checked: @checked, disabled: @disabled,
          class: cn(
            "peer size-[var(--control-box)] shrink-0 appearance-none rounded-sm border border-primary bg-container",
            "checked:bg-button-primary checked:border-button-primary",
            "focus-visible:outline-none focus-visible:ring-focus disabled:opacity-50 disabled:cursor-not-allowed",
            @html_options[:class]
          ),
          **@html_options.except(:class)
        ) +
        tag.svg(viewBox: "0 0 16 16", fill: "none",
          class: "pointer-events-none absolute inset-0 size-[var(--control-box)] p-0.5 text-inverse opacity-0 peer-checked:opacity-100") {
          tag.path(d: "M3 8l3.5 3.5L13 5", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round", fill: "none")
        }
      end
    end
  end
end
