module Ui
  # Interactive counterpart to Table: click a header to sort, type to filter,
  # page through results — all client-side, driven by app/javascript/controllers/data_table_controller.js.
  class DataTableComponent < ApplicationComponent
    def initialize(headers:, rows:, page_size: 5)
      @headers = headers
      @rows = rows
      @page_size = page_size
    end
  end
end
