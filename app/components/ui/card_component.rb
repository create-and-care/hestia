module Ui
  class CardComponent < ApplicationComponent
    renders_one :title
    renders_one :description
    renders_one :footer

    def initialize(class_name: nil)
      @class_name = class_name
    end
  end
end
