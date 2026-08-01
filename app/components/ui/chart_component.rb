module Ui
  # Minimal dependency-free bar chart. For richer charts, render real data through
  # a JS charting lib via a dedicated Stimulus controller instead of extending this.
  class ChartComponent < ApplicationComponent
    # Rotating categorical palette — module accent tokens, not raw Tailwind
    # colors, so bars adapt in dark mode and never render the old hardcoded
    # indigo brand color (#444CE7).
    COLORS = %w[bg-module-tasks bg-module-recipes bg-module-fridge bg-module-wellbeing bg-module-gifts].freeze

    # data: [["Jan", 42], ["Feb", 73], ...]
    # variant: :bar (default) or :line — line draws a single-series SVG polyline,
    # colored via the "text-module-#{color}" token so it follows the currentColor
    # convention shared with lucide_icon rather than needing stroke-* utilities.
    def initialize(data: [], height: 160, variant: :bar, color: "tasks")
      @data = data
      @height = height
      @variant = variant
      @color = color
      values = data.map { |(_, v)| v }
      @max = values.max.to_f.nonzero? || 1
      @min = [ values.min.to_f, 0 ].min
    end

    def line?
      @variant == :line
    end

    def color_class
      "text-module-#{@color}"
    end

    def line_points
      return "" if @data.size < 2

      range = (@max - @min).nonzero? || 1
      step = 100.0 / (@data.size - 1)
      @data.each_with_index.map do |(_, value), index|
        x = (index * step).round(2)
        y = (100 - ((value - @min) / range * 100)).round(2)
        "#{x},#{y}"
      end.join(" ")
    end
  end
end
