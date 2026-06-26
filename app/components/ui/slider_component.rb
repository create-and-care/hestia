module Ui
  class SliderComponent < ApplicationComponent
    def initialize(name: nil, min: 0, max: 100, value: 50, step: 1)
      @name = name
      @min = min
      @max = max
      @value = value
      @step = step
    end
  end
end
