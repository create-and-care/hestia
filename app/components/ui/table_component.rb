module Ui
  class TableComponent < ApplicationComponent
    def initialize(headers: [], rows: [])
      @headers = headers
      @rows = rows
    end
  end
end
