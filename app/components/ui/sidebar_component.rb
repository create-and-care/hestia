module Ui
  class SidebarComponent < ApplicationComponent
    renders_one :header
    # Sits between the header and the scrollable nav, so whatever it holds (the
    # app's global search entry) stays put while the nav scrolls under it. It is
    # a slot rather than part of `content` for exactly that reason: as plain
    # content it lived inside the scroller and drifted off-screen once a couple
    # of nav groups were expanded.
    renders_one :toolbar
    renders_one :footer

    def initialize(class_name: nil)
      @class_name = class_name
    end
  end
end
