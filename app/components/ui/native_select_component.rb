module Ui
  class NativeSelectComponent < ApplicationComponent
    SIZES = {
      sm: "h-[var(--control-h-sm)] text-xs",
      default: "h-[var(--control-h-default)] text-sm"
    }.freeze

    def initialize(name: nil, options: [], selected: nil, disabled: false, invalid: false, size: :default, html_options: {})
      @name = name
      @options = options
      @selected = selected
      @disabled = disabled
      @invalid = invalid
      @size = size
      @html_options = html_options
    end

    def call
      content_tag :select, name: @name, disabled: @disabled, "aria-invalid": @invalid, **@html_options.except(:class),
        class: cn(
          "flex w-full appearance-none rounded-md border bg-container px-3 text-primary",
          "focus-visible:outline-none focus-visible:ring-focus disabled:opacity-50",
          SIZES.fetch(@size),
          @invalid ? "border-destructive" : "border-primary",
          @html_options[:class]
        ) do
        safe_join(@options.map { |opt|
          label, value = opt.is_a?(Array) ? opt : [ opt, opt ]
          content_tag :option, label, value: value, selected: value == @selected
        })
      end
    end
  end
end
