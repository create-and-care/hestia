module Ui
  class ItemComponent < ApplicationComponent
    renders_one :leading
    renders_one :title
    renders_one :description
    renders_one :trailing

    def initialize(href: nil, active: false)
      @href = href
      @active = active
    end
  end
end
