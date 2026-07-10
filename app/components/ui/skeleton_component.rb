module Ui
  class SkeletonComponent < ApplicationComponent
    def initialize(class_name: "h-4 w-full")
      @class_name = class_name
    end

    def call
      tag.div "aria-hidden": "true", class: cn("bg-loader rounded-md", @class_name)
    end
  end
end
