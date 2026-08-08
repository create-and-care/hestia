module Ui
  class DialogComponent < ApplicationComponent
    renders_one :trigger
    renders_one :title
    renders_one :description
    renders_one :footer

    POSITION_CLASSES = {
      center: "m-auto rounded-lg w-full",
      high: "mt-[var(--panel-h-offset)] mb-auto mx-auto rounded-lg w-full",
      right: "ml-auto mr-0 h-full w-full rounded-l-lg",
      left: "mr-auto ml-0 h-full w-full rounded-r-lg",
      bottom: "mt-auto mb-0 w-full rounded-t-lg max-h-[var(--panel-h)]"
    }.freeze

    # The max-width used to be baked into POSITION_CLASSES, which meant every
    # centered dialog was max-w-md whatever it held — fine for a confirmation,
    # too narrow for a form with a row of fields in it (the fridge "add food"
    # dialog wrapped every one of its six controls onto its own line).
    SIZE_CLASSES = {
      sm: "max-w-sm", default: "max-w-md", lg: "max-w-2xl", xl: "max-w-4xl"
    }.freeze

    # Side sheets slide in from an edge, so they are sized as a share of the
    # screen rather than as a content column.
    SIDE_SIZE_CLASSES = {
      sm: "max-w-xs", default: "max-w-sm", lg: "max-w-lg", xl: "max-w-2xl"
    }.freeze

    # The content wrapper's height rule follows the placement. A side sheet's
    # <dialog> is already h-full, so capping its content at --panel-h left the panel
    # taller than anything inside it — invisible while the drawer's content was
    # the same white as the dialog, obvious the moment it paints its own
    # background (the mobile nav drawer). Everything else is anchored to one
    # edge and grows from its content, so there the cap is what does the work.
    CONTENT_CLASSES = {
      center: "max-h-[var(--panel-h)]", high: "max-h-[var(--panel-h-high)]", bottom: "max-h-[var(--panel-h)]",
      right: "h-full min-h-0", left: "h-full min-h-0"
    }.freeze

    # ...and the slot wrapper inside it has to pass that height on. It is a plain
    # block by default, which stops a percentage height on the caller's own root
    # from resolving — the caller ends up sized to its content with bare dialog
    # below it. flex-1 only ever claims *leftover* space, so on the placements
    # whose column is content-sized there is none to claim and nothing changes.
    BODY_CLASSES = { right: "flex-1 min-h-0", left: "flex-1 min-h-0" }.freeze

    # Mirrors shadcn: dialog/alert-dialog zoom, sheet/drawer slide from their side.
    ANIMATION_CLASSES = {
      center: "data-[state=open]:zoom-in-95 data-[state=closed]:zoom-out-95",
      high: "data-[state=open]:zoom-in-95 data-[state=closed]:zoom-out-95",
      right: "data-[state=open]:slide-in-from-right data-[state=closed]:slide-out-to-right",
      left: "data-[state=open]:slide-in-from-left data-[state=closed]:slide-out-to-left",
      bottom: "data-[state=open]:slide-in-from-bottom data-[state=closed]:slide-out-to-bottom"
    }.freeze

    def initialize(position: :center, size: :default, role: "dialog", full_width_trigger: false, close_on_submit: false, close_on_visit: false)
      @position = position
      @size = size
      @role = role
      @full_width_trigger = full_width_trigger
      @close_on_submit = close_on_submit
      @close_on_visit = close_on_visit
    end

    def size_class
      return nil if @position == :bottom # anchored to both edges; a max-width would strand it

      table = %i[right left].include?(@position) ? SIDE_SIZE_CLASSES : SIZE_CLASSES
      table.fetch(@size)
    end

    def trigger_wrapper_class
      @full_width_trigger ? "flex w-full" : "inline-flex"
    end

    def root_data_action
      actions = []
      actions << "turbo:submit-end->dialog#closeOnSuccess" if @close_on_submit
      # Opt-in for persistent-chrome drawers (e.g. the mobile nav) whose markup
      # survives a Turbo morph across pages — an ordinary full-page Visit
      # already tears the dialog down, so this only matters there.
      actions << "turbo:before-visit@document->dialog#close" if @close_on_visit
      actions.join(" ") if actions.any?
    end
  end
end
