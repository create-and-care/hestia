module Ui
  class PopoverComponent < ApplicationComponent
    renders_one :trigger

    # An enum rather than a `class_name` pass-through: two width (or padding)
    # utilities of equal specificity on the same element race in the compiled
    # stylesheet, and whichever Tailwind emits last wins regardless of which one
    # the caller passed (the trap documented in sidebar_controller.js).
    #
    # :menu is for a panel whose content is a list of full-width rows painting
    # their own hover — there the p-4 gutter reads as a misaligned inset, and
    # the narrower width keeps the panel inside the sidebar it hangs off.
    VARIANTS = { default: "w-72 p-4", menu: "w-64 p-1.5" }.freeze

    def initialize(placement: "bottom-start", variant: :default)
      @panel_id = "popover-#{SecureRandom.hex(4)}"
      @placement = placement
      @variant = variant
    end
  end
end
