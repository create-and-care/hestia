module Ui
  class MenubarComponent < ApplicationComponent
    # menus: [["File", [["New", "new"], ["Open", "open"]]], ["Edit", [["Undo", "undo"]]]]
    def initialize(menus: [])
      @menus = menus
    end
  end
end
