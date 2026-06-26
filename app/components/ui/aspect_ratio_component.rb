module Ui
  class AspectRatioComponent < ApplicationComponent
    def initialize(ratio: 16.0 / 9.0)
      @ratio = ratio
    end
  end
end
