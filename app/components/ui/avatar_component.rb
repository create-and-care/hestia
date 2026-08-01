module Ui
  class AvatarComponent < ApplicationComponent
    SIZES = { sm: "size-8 text-xs", default: "size-10 text-sm", lg: "size-14 text-base" }.freeze

    # Deterministic per-identity tint for the fallback-initials background —
    # keeps avatars distinguishable at a glance instead of uniform gray.
    FALLBACK_PALETTE = [
      "bg-brand/15 text-brand",
      "bg-accent/20 text-accent",
      "bg-cyan-500/15 text-cyan-600 dark:text-cyan-400",
      "bg-violet-500/15 text-violet-600 dark:text-violet-400",
      "bg-pink-500/15 text-pink-600 dark:text-pink-400"
    ].freeze

    # Optional per-module tint (courses, fridge, budget, ...) — keyed to the
    # same --module-* tokens as Ui::ModuleMedallionComponent, for avatars
    # that represent a household module rather than a person.
    MODULE_TINTS = {
      courses: "bg-module-courses/15 text-module-courses",
      fridge: "bg-module-fridge/15 text-module-fridge",
      budget: "bg-module-budget/15 text-module-budget",
      calendar: "bg-module-calendar/15 text-module-calendar",
      tasks: "bg-module-tasks/15 text-module-tasks",
      recipes: "bg-module-recipes/15 text-module-recipes",
      baby: "bg-module-baby/15 text-module-baby",
      gifts: "bg-module-gifts/15 text-module-gifts",
      pets: "bg-module-pets/15 text-module-pets",
      vehicles: "bg-module-vehicles/15 text-module-vehicles",
      messages: "bg-module-messages/15 text-module-messages",
      wellbeing: "bg-module-wellbeing/15 text-module-wellbeing"
    }.freeze

    def initialize(src: nil, alt: "", fallback: nil, size: :default, tint: nil, class_name: nil)
      @src = src
      @alt = alt
      @fallback = fallback || alt.to_s.split.map(&:first).first(2).join.upcase
      @size = size
      @tint = tint
      @class_name = class_name
    end

    def call
      content_tag :span, class: cn("relative inline-flex shrink-0 items-center justify-center overflow-hidden rounded-full font-medium", fallback_classes, SIZES.fetch(@size), @class_name) do
        if @src.present?
          image_tag @src, alt: @alt, class: "size-full object-cover bg-surface-inset"
        else
          @fallback
        end
      end
    end

    private

    def fallback_classes
      return "bg-surface-inset text-secondary" if @fallback.to_s.start_with?("+")
      return MODULE_TINTS.fetch(@tint) if @tint

      FALLBACK_PALETTE[@fallback.to_s.sum % FALLBACK_PALETTE.size]
    end
  end
end
