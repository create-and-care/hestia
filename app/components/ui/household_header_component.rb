module Ui
  # Household identity card — photo band, name, member avatars, note, and an
  # optional action — meant to sit once at the top of the dashboard.
  class HouseholdHeaderComponent < ApplicationComponent
    renders_one :photo
    renders_one :action

    def initialize(name:, note: nil, members: [], height: 180, class_name: nil)
      @name = name
      @note = note
      @members = members
      @height = height
      @class_name = class_name
    end
  end
end
