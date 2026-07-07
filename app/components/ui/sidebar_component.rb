module Ui
  class SidebarComponent < ApplicationComponent
    renders_one :header
    renders_one :footer

    def initialize(class_name: nil)
      @class_name = class_name
    end
  end
end
