module Ui
  class CalendarComponent < ApplicationComponent
    def initialize(name: nil, selected: nil)
      @name = name
      @selected = selected
    end
  end
end
