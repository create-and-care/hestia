module Ui
  # A small annotation dot for calling out a value — on a Chart, a map, or
  # any layout that needs to flag a point without a full Badge.
  class MarkerComponent < ApplicationComponent
    VARIANTS = {
      default: "bg-button-primary",
      accent: "bg-accent",
      success: "bg-success",
      warning: "bg-warning",
      destructive: "bg-destructive",
      info: "bg-info"
    }.freeze

    def initialize(variant: :default, label: nil, pulse: false)
      @variant = variant
      @label = label
      @pulse = pulse
    end

    def call
      tag.span(class: "inline-flex items-center gap-1.5") do
        safe_join([ dot, label_tag ].compact)
      end
    end

    private

    def dot
      tag.span(class: "relative inline-flex size-2.5") do
        safe_join([
          (tag.span(class: "absolute inline-flex size-full animate-ping rounded-full opacity-75 #{VARIANTS.fetch(@variant)}") if @pulse),
          tag.span(class: "relative inline-flex size-2.5 rounded-full #{VARIANTS.fetch(@variant)}")
        ].compact)
      end
    end

    def label_tag
      tag.span(@label, class: "text-xs font-medium text-primary") if @label
    end
  end
end
