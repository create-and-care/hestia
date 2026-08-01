module Ui
  class SkeletonComponent < ApplicationComponent
    def initialize(class_name: "h-4 w-full")
      @class_name = class_name
    end

    def call
      tag.div "aria-hidden": "true", class: cn("bg-loader", default_radius, @class_name)
    end

    private

    # Caller-supplied radius (e.g. "rounded-full" for an avatar skeleton) must
    # replace, not stack with, the default — same specificity means both would
    # otherwise render and the browser picks whichever comes last in the
    # compiled stylesheet, not whichever the caller intended.
    def default_radius
      "rounded-md" unless @class_name.to_s.match?(/(?:^|\s)rounded(-\S+)?(?:\s|$)/)
    end
  end
end
