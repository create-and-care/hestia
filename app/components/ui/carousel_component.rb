module Ui
  class CarouselComponent < ApplicationComponent
    class Slide < ApplicationComponent
      def call
        content
      end
    end

    renders_many :slides, Slide
  end
end
