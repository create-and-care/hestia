module Ui
  # Provides an RTL/LTR scope for the content it wraps.
  class DirectionComponent < ApplicationComponent
    def initialize(dir: :ltr)
      @dir = dir
    end

    def call
      tag.div dir: @dir do
        content
      end
    end
  end
end
