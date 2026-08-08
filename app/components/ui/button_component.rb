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
      sm: "h-[var(--control-h-sm)] px-3 text-sm gap-1.5",
      default: "h-[var(--control-h-default)] px-4 text-sm gap-2",
      lg: "h-[var(--control-h-lg)] px-6 text-base gap-2",
      icon: "size-[var(--control-h-default)] p-0 justify-center"
    }.freeze

    # The glyph is sized from the button's own size rather than from a
    # caller-supplied class, so a label and its icon cannot drift apart.
    ICON_SIZES = { sm: "size-4", default: "size-4", lg: "size-5", icon: "size-4" }.freeze

    # `icon:` is a convenience over what the block could always do — the
    # `gap-*` in SIZES has been there for icons from the start. It exists
    # because "the icon goes before the label, at this size" was being
    # re-decided at every call site, and about half of them were passing their
    # own size class.
    def initialize(variant: :default, size: :default, type: "button", disabled: false, href: nil,
      icon: nil, icon_position: :leading, html_options: {})
      @variant = variant
      @size = size
      @type = type
      @disabled = disabled
      @href = href
      @icon = icon
      @icon_position = icon_position
      @html_options = html_options
    end

    # The class list on its own, for the handful of call sites that cannot be
    # this component but must look exactly like it — a <button> a Stimulus
    # controller owns targets on, a trigger inside another component. They were
    # retyping the list by hand, which is how DataTable's pagination ended up
    # with a hardcoded 36px and DatePicker's trigger with a hardcoded 40px.
    #
    # Reach for the component first; this is the escape hatch, not the API.
    def self.classes(variant: :default, size: :default)
      new(variant: variant, size: size).send(:base_classes)
    end

    def call
      classes = base_classes

      if @href
        link_to @href, **@html_options, class: cn(classes, @html_options[:class]) do
          body
        end
      else
        content_tag :button, type: @type, disabled: @disabled, **@html_options, class: cn(classes, @html_options[:class]) do
          body
        end
      end
    end

    private
      def base_classes
        cn(
          "inline-flex items-center rounded-md font-medium transition-colors disabled:pointer-events-none disabled:opacity-50 focus-visible:ring-focus",
          # A button given `href:` renders as an anchor, and the global
          # `a:hover { text-decoration: underline }` in application.tailwind.css
          # then underlines its label on hover — which no button should do. The
          # :link variant is the one exception: it asks for that underline itself,
          # so it must not be handed the opt-out or the two would fight.
          (@variant == :link ? nil : "no-underline hover:no-underline"),
          VARIANTS.fetch(@variant),
          SIZES.fetch(@size)
        )
      end

      def body
        return content if @icon.blank?

        glyph = lucide_icon(@icon, css_class: ICON_SIZES.fetch(@size, "size-4"))
        # An icon-only button has no label to sit beside; anything else keeps
        # the block's content and puts the glyph on the side asked for.
        return glyph if @size == :icon && content.blank?

        @icon_position == :trailing ? safe_join([ content, glyph ]) : safe_join([ glyph, content ])
      end
  end
end
