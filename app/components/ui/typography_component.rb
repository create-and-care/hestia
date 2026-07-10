module Ui
  class TypographyComponent < ApplicationComponent
    TAGS = {
      h1: :h1, h2: :h2, h3: :h3, h4: :h4,
      p: :p, lead: :p, large: :p, small: :p, muted: :p,
      blockquote: :blockquote, inline_code: :code, list: :ul
    }.freeze

    VARIANTS = {
      h1: "scroll-m-20 text-4xl font-semibold tracking-tight text-primary",
      h2: "scroll-m-20 text-3xl font-semibold tracking-tight text-primary",
      h3: "scroll-m-20 text-2xl font-semibold tracking-tight text-primary",
      h4: "scroll-m-20 text-xl font-semibold tracking-tight text-primary",
      p: "text-sm leading-relaxed text-primary",
      lead: "text-lg text-secondary",
      large: "text-lg font-semibold text-primary",
      small: "text-sm font-medium leading-none text-primary",
      muted: "text-sm text-secondary",
      blockquote: "border-l-2 border-primary pl-4 italic text-secondary",
      inline_code: "rounded bg-surface-inset px-1.5 py-0.5 font-mono text-sm text-primary",
      list: "list-disc list-inside space-y-1 text-sm text-primary"
    }.freeze

    def initialize(variant: :p, html_options: {})
      @variant = variant
      @html_options = html_options
    end

    def call
      content_tag TAGS.fetch(@variant), **@html_options, class: cn(VARIANTS.fetch(@variant), @html_options[:class]) do
        content
      end
    end
  end
end
