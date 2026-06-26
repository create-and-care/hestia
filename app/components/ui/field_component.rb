module Ui
  class FieldComponent < ApplicationComponent
    renders_one :label
    renders_one :control
    renders_one :description
    renders_one :error

    def initialize(id: nil)
      @id = id
    end
  end
end
