module Ui
  class DrawerComponent < ApplicationComponent
    renders_one :trigger
    renders_one :title
    renders_one :description
    renders_one :footer

    def initialize(side: :bottom, close_on_visit: false)
      @side = side
      @close_on_visit = close_on_visit
    end
  end
end
