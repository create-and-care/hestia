module Ui
  class SheetComponent < ApplicationComponent
    renders_one :trigger
    renders_one :title
    renders_one :description
    renders_one :footer

    def initialize(side: :right)
      @side = side
    end
  end
end
