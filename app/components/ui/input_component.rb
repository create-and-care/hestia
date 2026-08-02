module Ui
  class InputComponent < ApplicationComponent
    SIZES = {
      sm: "h-[var(--control-h-sm)] text-xs",
      default: "h-[var(--control-h-default)] text-sm"
    }.freeze

    def initialize(type: "text", name: nil, value: nil, placeholder: nil, disabled: false, invalid: false, size: :default, html_options: {})
      @type = type
      @name = name
      @value = value
      @placeholder = placeholder
      @disabled = disabled
      @invalid = invalid
      @size = size
      @html_options = html_options
    end

    def call
      tag.input(
        type: @type, name: @name, value: @value, placeholder: @placeholder, disabled: @disabled,
        "aria-invalid": @invalid,
        **@html_options.except(:class),
        class: cn(
          "flex w-full rounded-md border bg-container px-3 text-primary placeholder:text-subdued",
          "focus-visible:outline-none focus-visible:ring-focus disabled:opacity-50 disabled:cursor-not-allowed",
          SIZES.fetch(@size),
          @invalid ? "border-destructive" : "border-primary",
          @html_options[:class]
        )
      )
    end
  end
end
