module Ui
  class ToggleComponent < ApplicationComponent
    def initialize(pressed: false)
      @pressed = pressed
    end

    def call
      tag.button type: "button", "aria-pressed": @pressed, data: { controller: "toggle", action: "click->toggle#toggle" },
        class: "inline-flex items-center justify-center size-9 rounded-md text-secondary aria-pressed:bg-surface-inset aria-pressed:text-primary hover:bg-surface-hover" do
        content
      end
    end
  end
end
