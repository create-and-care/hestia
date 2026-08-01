module Ui
  # A single chat message bubble, aligned by role — the building block
  # Ui::MessageComponent wraps with an avatar and a timestamp.
  class BubbleComponent < ApplicationComponent
    VARIANTS = {
      user: "ml-auto bg-button-primary text-inverse",
      assistant: "mr-auto bg-surface text-primary border border-primary"
    }.freeze

    def initialize(variant: :assistant)
      @variant = variant
    end

    def call
      # A fixed cap (rather than a viewport-relative %) so short messages don't wrap onto a
      # second line just because the row happens to be narrow (e.g. mobile) — only long
      # messages that actually exceed this width wrap.
      tag.div(content, class: cn("max-w-[85%] rounded-2xl px-4 py-2.5 text-sm leading-relaxed break-words sm:max-w-md", VARIANTS.fetch(@variant)))
    end
  end
end
