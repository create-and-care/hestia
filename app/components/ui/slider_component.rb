module Ui
  class SliderComponent < ApplicationComponent
    def initialize(name: nil, min: 0, max: 100, value: 50, step: 1, label: nil)
      @name = name
      @min = min
      @max = max
      @value = value
      @step = step
      @label = label
    end
  end
end
