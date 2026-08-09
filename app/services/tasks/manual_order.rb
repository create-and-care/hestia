module Tasks
  # Manual ordering of the general task list — the drag-and-drop handle and the
  # keyboard move buttons both come through here, and so do the views, which ask
  # before drawing either control.
  #
  # `position` is column-local. Every writer numbers one category from zero:
  # TasksController#sort groups by task_category_id before assigning 0..n, and a
  # drag sends the ids of a single board column to Reordering. So two tasks in
  # different categories routinely hold the same number, and the value orders a
  # task against its own category's tasks and nothing else.
  #
  # The agenda buckets by due date, so one bucket mixes categories, and reading
  # position across that bucket reads a number that was never comparable.
  # Swapping it between a "Maison" task and a "Courses" task reshuffles both
  # columns on the board — a move invisible from the agenda and impossible to
  # undo there — and when the two happen to hold the same number the swap moves
  # nothing at all. Neither is what the person pressing the arrow asked for.
  #
  # Hence: manual ordering is a board operation, and stays one until tasks carry
  # a rank that spans categories. Everything below is written against the board's
  # grouping, and every caller checks .available_in? first.
  class ManualOrder
    def self.available_in?(view_mode)
      view_mode == "board"
    end

    # Applies a dragged order — the ids of one board column, top to bottom.
    # Returns false, having written nothing, when the view cannot order tasks.
    def self.apply(household:, ids:, view_mode:)
      return false unless available_in?(view_mode)

      Reordering.apply(household.tasks, ids)
      true
    end

    # Swaps a task with its neighbour in the same board column. Returns false
    # when the view cannot order tasks, or when the task is already at the end
    # it is being moved towards.
    def self.move(task:, direction:, view_mode:)
      return false unless available_in?(view_mode)

      siblings = column_of(task)
      index = siblings.index(task)
      return false unless index && (index + direction).between?(0, siblings.size - 1)

      sibling = siblings[index + direction]
      task.position, sibling.position = sibling.position, task.position
      task.save!
      sibling.save!
      true
    end

    # A board column: one category, one done state. `ordered` is not decoration
    # — without it the SELECT carries no ORDER BY at all and Postgres is free to
    # return rows in heap order, so a move would swap with an arbitrary sibling
    # or, when the task landed last in that arbitrary order, do nothing.
    def self.column_of(task)
      task.household.tasks.general.ordered
        .where(done: task.done, task_category_id: task.task_category_id)
        .to_a
    end
    private_class_method :column_of
  end
end
