module Ui
  class AvatarComponent < ApplicationComponent
    SIZES = { sm: "size-7 text-xs", default: "size-9 text-sm", lg: "size-12 text-base" }.freeze

    # Deterministic per-identity tint for the fallback-initials background —
    # keeps avatars distinguishable at a glance instead of uniform gray.
    FALLBACK_PALETTE = [
      "bg-brand/15 text-brand",
      "bg-accent/20 text-accent",
      "bg-cyan-500/15 text-cyan-600 dark:text-cyan-400",
      "bg-violet-500/15 text-violet-600 dark:text-violet-400",
      "bg-pink-500/15 text-pink-600 dark:text-pink-400"
    ].freeze

    def initialize(src: nil, alt: "", fallback: nil, size: :default)
      @src = src
      @alt = alt
      @fallback = fallback || alt.to_s.split.map(&:first).first(2).join.upcase
      @size = size
    end

    def call
      content_tag :span, class: cn("relative inline-flex shrink-0 items-center justify-center overflow-hidden rounded-full font-medium", fallback_classes, SIZES.fetch(@size)) do
        if @src.present?
          image_tag @src, alt: @alt, class: "size-full object-cover"
        else
          @fallback
        end
      end
    end

    private

    def fallback_classes
      FALLBACK_PALETTE[@fallback.to_s.sum % FALLBACK_PALETTE.size]
    end
  end
end
