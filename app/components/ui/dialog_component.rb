module Ui
  class DialogComponent < ApplicationComponent
    renders_one :trigger
    renders_one :title
    renders_one :description
    renders_one :footer

    POSITION_CLASSES = {
      center: "m-auto rounded-lg max-w-md w-full",
      high: "mt-[25vh] mb-auto mx-auto rounded-lg max-w-md w-full",
      right: "ml-auto mr-0 h-full max-w-sm w-full rounded-l-lg",
      left: "mr-auto ml-0 h-full max-w-sm w-full rounded-r-lg",
      bottom: "mt-auto mb-0 w-full rounded-t-lg max-h-[80vh]"
    }.freeze

    # Mirrors shadcn: dialog/alert-dialog zoom, sheet/drawer slide from their side.
    ANIMATION_CLASSES = {
      center: "data-[state=open]:zoom-in-95 data-[state=closed]:zoom-out-95",
      high: "data-[state=open]:zoom-in-95 data-[state=closed]:zoom-out-95",
      right: "data-[state=open]:slide-in-from-right data-[state=closed]:slide-out-to-right",
      left: "data-[state=open]:slide-in-from-left data-[state=closed]:slide-out-to-left",
      bottom: "data-[state=open]:slide-in-from-bottom data-[state=closed]:slide-out-to-bottom"
    }.freeze

    def initialize(position: :center, role: "dialog", full_width_trigger: false)
      @position = position
      @role = role
      @full_width_trigger = full_width_trigger
    end

    def trigger_wrapper_class
      @full_width_trigger ? "flex w-full" : "inline-flex"
    end
  end
end
