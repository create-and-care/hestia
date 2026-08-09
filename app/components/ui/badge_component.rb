module Ui
  class BadgeComponent < ApplicationComponent
    VARIANTS = {
      default: "bg-button-primary text-inverse",
      secondary: "bg-surface-inset text-primary",
      outline: "bg-transparent text-primary border border-primary",
      accent: "bg-accent/10 text-accent",
      success: "bg-success/10 text-success",
      warning: "bg-warning/10 text-warning",
      destructive: "bg-destructive/10 text-destructive"
    }.freeze

    def initialize(variant: :default, html_options: {})
      @variant = variant
      @html_options = html_options
    end

    def call
      content_tag :span, **@html_options,
        class: cn("on-tone inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium gap-1", VARIANTS.fetch(@variant), @html_options[:class]) do
        content
      end
    end
  end
end
