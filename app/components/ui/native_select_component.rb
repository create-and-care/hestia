module Ui
  class NativeSelectComponent < ApplicationComponent
    def initialize(name: nil, options: [], selected: nil, disabled: false, html_options: {})
      @name = name
      @options = options
      @selected = selected
      @disabled = disabled
      @html_options = html_options
    end

    def call
      content_tag :select, name: @name, disabled: @disabled, **@html_options.except(:class),
        class: cn(
          "flex h-9 w-full appearance-none rounded-md border border-primary bg-container px-3 text-sm text-primary",
          "focus-visible:outline-none focus-visible:ring-focus disabled:opacity-50",
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
