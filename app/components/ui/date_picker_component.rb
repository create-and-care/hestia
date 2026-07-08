module Ui
  # Composes Popover + Calendar: the pattern shadcn/ui documents as "Date
  # Picker" rather than a standalone primitive. Selecting a day (via the
  # calendar controller's calendar:select event) updates the trigger label
  # and closes the popover — see app/javascript/controllers/date_picker_controller.js.
  class DatePickerComponent < ApplicationComponent
    def initialize(name: nil, selected: nil, placeholder: "Choisir une date")
      @name = name
      @selected = selected
      @placeholder = placeholder
    end
  end
end
