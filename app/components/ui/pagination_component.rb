module Ui
  class PaginationComponent < ApplicationComponent
    def initialize(current:, total:, path:)
      @current = current
      @total = total
      @path = path
    end

    private

    def page_href(page)
      @path.call(page)
    end
  end
end
