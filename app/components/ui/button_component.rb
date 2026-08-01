module Ui
  class ButtonComponent < ApplicationComponent
    VARIANTS = {
      default: "bg-button-primary text-inverse hover:bg-button-primary-hover",
      secondary: "bg-button-secondary text-primary hover:bg-button-secondary-hover",
      outline: "bg-transparent text-primary border border-primary hover:bg-button-outline-hover",
      ghost: "bg-transparent text-primary hover:bg-button-ghost-hover",
      destructive: "bg-button-destructive text-inverse hover:bg-button-destructive-hover",
      link: "bg-transparent text-link underline-offset-4 hover:underline"
    }.freeze

    SIZES = {
      sm: "h-9 px-3 text-sm gap-1.5",
      default: "h-10 px-4 text-sm gap-2",
      lg: "h-11 px-6 text-base gap-2",
      icon: "size-10 p-0 justify-center"
    }.freeze

    def initialize(variant: :default, size: :default, type: "button", disabled: false, href: nil, html_options: {})
      @variant = variant
      @size = size
      @type = type
      @disabled = disabled
      @href = href
      @html_options = html_options
    end

    def call
      classes = cn(
        "inline-flex items-center rounded-md font-medium transition-colors disabled:pointer-events-none disabled:opacity-50 focus-visible:ring-focus",
        VARIANTS.fetch(@variant),
        SIZES.fetch(@size)
      )

      if @href
        link_to @href, **@html_options, class: cn(classes, @html_options[:class]) do
          content
        end
      else
        content_tag :button, type: @type, disabled: @disabled, **@html_options, class: cn(classes, @html_options[:class]) do
          content
        end
      end
    end
  end
end
