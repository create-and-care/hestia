class TasksController < ApplicationController
  include TaskViewMode

  FAR_FUTURE = Date.new(9999, 12, 31)

  # Agenda buckets, in the order they are shown. A task lands in the first one
  # whose test it passes, so "done" wins over any due date and the overdue
  # bucket wins over today's.
  AGENDA_GROUPS = [
    [ :overdue,   ->(task) { task.due_on && task.due_on < Date.current } ],
    [ :today,     ->(task) { task.due_on == Date.current } ],
    [ :this_week, ->(task) { task.due_on && task.due_on <= Date.current.end_of_week } ],
    [ :later,     ->(task) { task.due_on.present? } ],
    [ :someday,   ->(task) { true } ]
  ].freeze

  before_action :set_task, only: %i[edit update destroy toggle move_up move_down]

  def index
    @query = params[:q].to_s.strip
    @view_mode = task_view_mode
    @categories = Current.household.task_categories.order(:name)

    # :assignee for the card's avatar. :task_category too in agenda mode, which
    # names each task's category on the row itself — the board doesn't, since it
    # takes its column headings from @categories and groups on the foreign key.
    tasks = Current.household.tasks.general.ordered.includes(:assignee)
    tasks = tasks.includes(:task_category) if @view_mode == "agenda"
    tasks = tasks.where("title ILIKE :q OR description ILIKE :q OR emoji ILIKE :q", q: "%#{@query}%") if @query.present?
    @tasks = tasks.to_a

    @columns = @categories.map { |category| [ category, @tasks.select { |t| t.task_category_id == category.id } ] }
    @columns << [ nil, @tasks.select { |t| t.task_category_id.nil? } ]
    @columns = @columns.reject { |(_, tasks)| tasks.empty? } if @query.present?

    @agenda = agenda_groups(@tasks)
    @task = Task.new
  end

  def create
    Tasks::CreateTask.call(
      household: Current.household,
      title: task_params[:title],
      description: task_params[:description],
      emoji: task_params[:emoji],
      due_on: task_params[:due_on],
      assignee: find_member(task_params[:assignee_id]),
      task_category: find_category(task_params[:task_category_id])
    )

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tasks_path }
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to tasks_path, alert: t(".alert")
  end

  def edit
  end

  def update
    @task.assign_attributes(
      title: task_params[:title],
      description: task_params[:description],
      due_on: task_params[:due_on]
    )
    # The edit form has no Emoji input (removed — Hest.AI/API-set emojis are the only
    # remaining source), so only touch it when a caller explicitly sends the key.
    @task.emoji = task_params[:emoji] if params[:task].key?(:emoji)
    @task.assignee = find_member(task_params[:assignee_id])
    @task.task_category = find_category(task_params[:task_category_id])

    if @task.save
      respond_to do |format|
        format.turbo_stream { head :no_content } # closes the modal; the card updates via the real-time stream
        format.html { redirect_to tasks_path, notice: t(".notice") }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle
    Tasks::ToggleTask.call(task: @task)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(@task) }
      format.html { redirect_to tasks_path }
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@task) }
      format.html { redirect_to tasks_path }
    end
  end

  def reorder
    Reordering.apply(Current.household.tasks, params[:ids])
    head :no_content
  end

  # Keyboard-accessible alternative to the drag-and-drop reorder handle —
  # swaps position with the adjacent task in the same column (category).
  def move_up
    swap_with_sibling(-1)
    redirect_to tasks_path
  end

  def move_down
    swap_with_sibling(1)
    redirect_to tasks_path
  end

  # One-off auto-sort by due date or by assignee — rewrites
  # position within each column without locking out manual drag-and-drop
  # reordering afterward, since it's just a regular position update.
  def sort
    return redirect_to(tasks_path) unless %w[due_date assignee].include?(params[:by])

    Current.household.tasks.general.where(done: false).group_by(&:task_category_id).each_value do |tasks|
      sorted = if params[:by] == "due_date"
        tasks.sort_by { |t| t.due_on || FAR_FUTURE }
      else
        tasks.sort_by { |t| t.assignee&.name.presence || t.assignee&.email_address || "" }
      end

      sorted.each_with_index { |t, index| t.update!(position: index) }
    end

    redirect_to tasks_path, notice: t(".notice")
  end

  private
    # Open tasks bucketed by when they are due, plus a trailing "done" bucket.
    # Within a bucket the household's own drag-and-drop order is preserved
    # (@tasks arrives `ordered`), so sorting by due date still means something
    # here rather than being overridden by the grouping.
    def agenda_groups(tasks)
      open_tasks, done_tasks = tasks.partition { |task| !task.done? }

      groups = AGENDA_GROUPS.filter_map do |key, test|
        matching = open_tasks.select(&test)
        open_tasks -= matching
        [ key, matching ] if matching.any?
      end

      groups << [ :done, done_tasks ] if done_tasks.any?
      groups
    end

    def set_task
      @task = Current.household.tasks.find(params[:id])
    end

    # `ordered` is not decoration: "the task above" only means anything in the
    # order the column is actually displayed in (#index sorts the same way).
    # Without it the SELECT has no ORDER BY at all and Postgres is free to
    # return rows in heap order, so move_up could swap with an arbitrary
    # sibling — or, when the task landed last in that arbitrary order, do
    # nothing at all.
    def swap_with_sibling(direction)
      siblings = Current.household.tasks.general.ordered
        .where(done: @task.done, task_category_id: @task.task_category_id).to_a
      index = siblings.index(@task)
      sibling = siblings[index + direction] if index && (index + direction).between?(0, siblings.size - 1)
      return unless sibling

      @task.position, sibling.position = sibling.position, @task.position
      @task.save!
      sibling.save!
    end

    def find_member(id)
      Current.household.users.find_by(id: id) if id.present?
    end

    def find_category(id)
      Current.household.task_categories.find_by(id: id) if id.present?
    end

    def task_params
      params.require(:task).permit(:title, :description, :emoji, :due_on, :assignee_id, :task_category_id)
    end
end
