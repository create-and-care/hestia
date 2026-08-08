module Ui
  class SheetComponent < ApplicationComponent
    renders_one :trigger
    renders_one :title
    renders_one :description
    renders_one :footer

    def initialize(side: :right, size: :default)
      @side = side
      @size = size
    end
  end
end
