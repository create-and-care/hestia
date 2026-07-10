module Ui
  class CommandComponent < ApplicationComponent
    # groups: [["Suggestions", [["Calendar", "calendar"], ["Search", "search"]]], ...]
    def initialize(groups: [], placeholder: "Type a command or search…", id: nil)
      @groups = groups
      @placeholder = placeholder
      @id = id || "command-#{SecureRandom.hex(4)}"
    end

    def list_id
      "#{@id}-list"
    end

    def item_id(index)
      "#{@id}-item-#{index}"
    end
  end
end
