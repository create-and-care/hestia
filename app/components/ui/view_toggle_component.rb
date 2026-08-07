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

    # The counterpart of CONTAINER_CLASSES, for the rows that go *inside* it.
    # It existed only as an unwritten rule, and views kept getting it wrong in
    # the same direction: in list mode the container already draws the outline
    # and the divide-y separators, so a row must contribute nothing but padding.
    # Giving it a border and a radius of its own is what puts a rounded, boxed
    # card on every row *inside* the box. In grid mode there is no container
    # chrome at all, so there each row does have to be a card in its own right.
    #
    # Rows built on Ui::ItemComponent (pets, contacts, notes, documents…) are
    # already correct without this — that component deliberately draws no
    # border. This is for the views that lay out their own row markup.
    ITEM_CLASSES = {
      "list" => "px-4 py-3",
      "grid" => "rounded-lg border border-primary bg-container p-4 shadow-xs"
    }.freeze

    def self.container_classes(mode)
      CONTAINER_CLASSES.fetch(mode, CONTAINER_CLASSES["list"])
    end

    def self.item_classes(mode)
      ITEM_CLASSES.fetch(mode, ITEM_CLASSES["list"])
    end
  end
end
