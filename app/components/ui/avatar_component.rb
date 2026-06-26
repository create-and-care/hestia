module Ui
  class AvatarComponent < ApplicationComponent
    SIZES = { sm: "size-7 text-xs", default: "size-9 text-sm", lg: "size-12 text-base" }.freeze

    def initialize(src: nil, alt: "", fallback: nil, size: :default)
      @src = src
      @alt = alt
      @fallback = fallback || alt.to_s.split.map(&:first).first(2).join.upcase
      @size = size
    end

    def call
      content_tag :span, class: cn("relative inline-flex shrink-0 items-center justify-center overflow-hidden rounded-full bg-surface-inset text-secondary font-medium", SIZES.fetch(@size)) do
        if @src.present?
          image_tag @src, alt: @alt, class: "size-full object-cover"
        else
          @fallback
        end
      end
    end
  end
end
