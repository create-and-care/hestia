module Ui
  class ItemComponent < ApplicationComponent
    renders_one :leading
    renders_one :title
    renders_one :description
    renders_one :trailing

    def initialize(href: nil)
      @href = href
    end
  end
end
