module Ui
  class ButtonGroupComponent < ApplicationComponent
    def initialize(orientation: :horizontal)
      @orientation = orientation
    end

    def call
      tag.div role: "group", class: cn(
        "inline-flex",
        @orientation == :vertical ? "flex-col [&>*]:rounded-none [&>*:first-child]:rounded-t-md [&>*:last-child]:rounded-b-md [&>*:not(:first-child)]:-mt-px" :
                                     "[&>*]:rounded-none [&>*:first-child]:rounded-l-md [&>*:last-child]:rounded-r-md [&>*:not(:first-child)]:-ml-px"
      ) do
        content
      end
    end
  end
end
