class TasksController < ApplicationController
  FAR_FUTURE = Date.new(9999, 12, 31)

  before_action :set_task, only: %i[edit update destroy toggle move_up move_down]

  def index
    @query = params[:q].to_s.strip
    @categories = Current.household.task_categories.order(:name)

    tasks = Current.household.tasks.general.ordered.includes(:assignee, :task_category)
    tasks = tasks.where("title ILIKE :q OR description ILIKE :q OR emoji ILIKE :q", q: "%#{@query}%") if @query.present?
    @tasks = tasks.to_a

    @columns = @categories.map { |category| [ category, @tasks.select { |t| t.task_category_id == category.id } ] }
    @columns << [ nil, @tasks.select { |t| t.task_category_id.nil? } ]
    @columns = @columns.reject { |(_, tasks)| tasks.empty? } if @query.present?

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
    def set_task
      @task = Current.household.tasks.find(params[:id])
    end

    def swap_with_sibling(direction)
      siblings = Current.household.tasks.general.where(done: @task.done, task_category_id: @task.task_category_id).to_a
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
