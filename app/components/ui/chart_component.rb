module Ui
  # Minimal dependency-free bar chart. For richer charts, render real data through
  # a JS charting lib via a dedicated Stimulus controller instead of extending this.
  class ChartComponent < ApplicationComponent
    COLORS = %w[bg-blue-500 bg-violet-500 bg-cyan-500 bg-green-500 bg-orange-500].freeze

    # data: [["Jan", 42], ["Feb", 73], ...]
    def initialize(data: [], height: 160)
      @data = data
      @height = height
      @max = data.map { |(_, v)| v }.max.to_f.nonzero? || 1
    end
  end
end
