module Ui
  # Minimal dependency-free bar chart. For richer charts, render real data through
  # a JS charting lib via a dedicated Stimulus controller instead of extending this.
  class ChartComponent < ApplicationComponent
    # Rotating categorical palette — module accent tokens, not raw Tailwind
    # colors, so bars adapt in dark mode and never render the old hardcoded
    # indigo brand color (#444CE7).
    COLORS = %w[bg-module-tasks bg-module-recipes bg-module-fridge bg-module-wellbeing bg-module-gifts].freeze

    # data: [["Jan", 42], ["Feb", 73], ...]
    def initialize(data: [], height: 160)
      @data = data
      @height = height
      @max = data.map { |(_, v)| v }.max.to_f.nonzero? || 1
    end
  end
end
