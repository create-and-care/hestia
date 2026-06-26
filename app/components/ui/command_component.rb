module Ui
  class CommandComponent < ApplicationComponent
    # groups: [["Suggestions", [["Calendar", "calendar"], ["Search", "search"]]], ...]
    def initialize(groups: [], placeholder: "Type a command or search…")
      @groups = groups
      @placeholder = placeholder
    end
  end
end
