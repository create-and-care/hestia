module Ui
  class ProgressComponent < ApplicationComponent
    def initialize(value: 0, max: 100)
      @value = value.clamp(0, max)
      @max = max
    end
  end
end
