module Ui
  # List/grid switch for a collection view — pair with CollectionViewMode
  # in the controller. path_for receives "list" or "grid" and must return
  # the current page's URL with that view mode applied.
  class ViewToggleComponent < ApplicationComponent
    # Shared classes for the collection container itself, so every view
    # wiring this component stays visually consistent.
    CONTAINER_CLASSES = {
      "list" => "flex flex-col divide-y divide-primary rounded-lg border border-primary",
      "grid" => "grid gap-3 sm:grid-cols-2 lg:grid-cols-3"
    }.freeze

    def initialize(mode:, path_for:)
      @mode = mode
      @path_for = path_for
    end

    def self.container_classes(mode)
      CONTAINER_CLASSES.fetch(mode, CONTAINER_CLASSES["list"])
    end
  end
end
