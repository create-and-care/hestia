module Ui
  # Scroll-anchored container for a Message thread: stays pinned to the
  # bottom as content is appended, and surfaces a "new messages" button
  # when the reader has scrolled up. See message_scroller_controller.js.
  class MessageScrollerComponent < ApplicationComponent
    def initialize(class_name: "h-80")
      @class_name = class_name
    end
  end
end
