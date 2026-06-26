module Ui
  class TextareaComponent < ApplicationComponent
    def initialize(name: nil, placeholder: nil, rows: 4, disabled: false, html_options: {})
      @name = name
      @placeholder = placeholder
      @rows = rows
      @disabled = disabled
      @html_options = html_options
    end

    def call
      content_tag :textarea, content, name: @name, placeholder: @placeholder, rows: @rows, disabled: @disabled,
        **@html_options.except(:class),
        class: cn(
          "flex w-full rounded-md border border-primary bg-container px-3 py-2 text-sm text-primary placeholder:text-subdued",
          "focus-visible:outline-none focus-visible:ring-focus disabled:opacity-50 disabled:cursor-not-allowed",
          @html_options[:class]
        )
    end
  end
end
