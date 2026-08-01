module Ui
  class AvatarComponent < ApplicationComponent
    SIZES = { sm: "size-8 text-xs", default: "size-10 text-sm", lg: "size-14 text-base" }.freeze

    # Per-module tint — keyed to the same --module-* tokens as
    # Ui::ModuleMedallionComponent. Also doubles as the fallback pool: with no
    # explicit `tint`, an avatar hashes into one of these 12 by identity, so
    # people-avatars and module-avatars draw from a single palette rather than
    # two visually-unrelated ones.
    MODULE_TINTS = {
      courses: "bg-module-courses/14 text-module-courses",
      fridge: "bg-module-fridge/14 text-module-fridge",
      budget: "bg-module-budget/14 text-module-budget",
      calendar: "bg-module-calendar/14 text-module-calendar",
      tasks: "bg-module-tasks/14 text-module-tasks",
      recipes: "bg-module-recipes/14 text-module-recipes",
      baby: "bg-module-baby/14 text-module-baby",
      gifts: "bg-module-gifts/14 text-module-gifts",
      pets: "bg-module-pets/14 text-module-pets",
      vehicles: "bg-module-vehicles/14 text-module-vehicles",
      messages: "bg-module-messages/14 text-module-messages",
      wellbeing: "bg-module-wellbeing/14 text-module-wellbeing"
    }.freeze

    MODULES = MODULE_TINTS.keys.freeze

    # tint: a module key (:courses, :fridge, ...) for a Tailwind-driven tint
    # that adapts in dark mode, OR any raw CSS color ("#A85030",
    # "rebeccapurple") applied via inline style. Raw colors can't be Tailwind
    # classes — arbitrary values need to appear literally in source for the
    # build-time scanner to pick them up, and a value from a member record
    # never does.
    def initialize(src: nil, alt: "", fallback: nil, size: :default, tint: nil, class_name: nil)
      @src = src
      @alt = alt
      @fallback = fallback || alt.to_s.split.map(&:first).first(2).join.upcase
      @size = size
      @tint = tint
      @class_name = class_name
    end

    def call
      content_tag :span,
        class: cn("relative inline-flex shrink-0 items-center justify-center overflow-hidden rounded-full font-medium", fallback_classes, SIZES.fetch(@size), @class_name),
        style: fallback_style do
        if @src.present?
          image_tag @src, alt: @alt, class: "size-full object-cover bg-surface-inset"
        else
          @fallback
        end
      end
    end

    private

    def overflow?
      @fallback.to_s.start_with?("+")
    end

    def raw_color_tint?
      !overflow? && @tint.present? && !MODULES.include?(@tint.to_sym)
    end

    def module_key
      @tint.present? ? @tint.to_sym : MODULES[@fallback.to_s.sum % MODULES.size]
    end

    def fallback_classes
      return "bg-surface-inset text-secondary" if overflow?
      return nil if raw_color_tint?

      MODULE_TINTS.fetch(module_key)
    end

    def fallback_style
      return nil unless raw_color_tint?

      "background-color: color-mix(in oklab, #{@tint} 14%, transparent); color: #{@tint};"
    end
  end
end
