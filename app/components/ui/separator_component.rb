module Ui
  class SeparatorComponent < ApplicationComponent
    def initialize(orientation: :horizontal)
      @orientation = orientation
    end

    def call
      tag.div role: "separator", "aria-orientation": (@orientation == :vertical ? "vertical" : nil), class: cn(
        "bg-tertiary",
        @orientation == :vertical ? "w-px h-full" : "h-px w-full"
      )
    end
  end
end
