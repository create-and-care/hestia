module Ui
  class DrawerComponent < ApplicationComponent
    renders_one :trigger
    renders_one :title
    renders_one :description
    renders_one :footer

    def initialize(side: :bottom)
      @side = side
    end
  end
end
