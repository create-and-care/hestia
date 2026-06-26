module Ui
  class BreadcrumbComponent < ApplicationComponent
    # items: [["Home", "/"], ["Settings", "/settings"], ["Profile", nil]] (last item = current page, no href)
    def initialize(items: [])
      @items = items
    end
  end
end
