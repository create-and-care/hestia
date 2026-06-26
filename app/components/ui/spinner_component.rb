module Ui
  class SpinnerComponent < ApplicationComponent
    SIZES = { sm: "size-4", default: "size-5", lg: "size-7" }.freeze

    def initialize(size: :default)
      @size = size
    end

    def call
      content_tag :svg, viewBox: "0 0 24 24", fill: "none", class: cn("animate-spin text-secondary", SIZES.fetch(@size)), role: "status", "aria-label": "Loading" do
        tag.circle(cx: "12", cy: "12", r: "10", stroke: "currentColor", "stroke-width": "3", "stroke-opacity": "0.25", fill: "none") +
        tag.path(d: "M22 12a10 10 0 0 0-10-10", stroke: "currentColor", "stroke-width": "3", "stroke-linecap": "round", fill: "none")
      end
    end
  end
end
