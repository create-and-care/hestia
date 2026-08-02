module Ui
  # Circular icon badge — a tinted background at 12% behind a module-colored
  # glyph (see --module-* tokens), so many household domains stay scannable
  # without 12 distinct icon styles. Purely presentational: the module name
  # is conveyed by adjacent text at call sites, so the icon stays aria-hidden.
  class ModuleMedallionComponent < ApplicationComponent
    MODULES = %i[courses fridge budget calendar tasks recipes baby gifts pets vehicles messages wellbeing].freeze

    SIZES = { sm: "size-8", default: "size-11", lg: "size-16" }.freeze
    GLYPH_SIZES = { sm: "size-3.5", default: "size-5", lg: "size-7" }.freeze

    # mod: one of MODULES, or nil/unknown for callers with no module mapping
    # yet (e.g. sidebar rows) — those render the same shape with a neutral
    # surface-inset tint instead of raising, so geometry never breaks while a
    # mapping is undecided. Named `mod`, not `module`, since the latter is a
    # Ruby keyword and can't be referenced as a bare local inside the method body.
    def initialize(mod: nil, icon:, size: :default, class_name: nil)
      @mod = mod
      @icon = icon
      @size = size
      @class_name = class_name
    end

    def call
      tag.span class: cn(
        "inline-flex shrink-0 items-center justify-center rounded-full",
        known_module? ? "bg-module-#{@mod}/12 text-module-#{@mod}" : "bg-surface-inset text-secondary",
        SIZES.fetch(@size), @class_name
      ) do
        lucide_icon_mask(@icon, css_class: GLYPH_SIZES.fetch(@size))
      end
    end

    private

      def known_module?
        MODULES.include?(@mod)
      end
  end
end
