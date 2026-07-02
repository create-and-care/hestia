class TasksController < ApplicationController
  before_action :set_task, only: %i[edit update destroy toggle]

  def index
    @query = params[:q].to_s.strip
    @categories = Current.household.task_categories.order(:name)

    tasks = Current.household.tasks.general.ordered.includes(:assignee, :task_category)
    tasks = tasks.where("title ILIKE ?", "%#{@query}%") if @query.present?
    @tasks = tasks.to_a

    @columns = @categories.map { |category| [ category, @tasks.select { |t| t.task_category_id == category.id } ] }
    @columns << [ nil, @tasks.select { |t| t.task_category_id.nil? } ]

    @task = Task.new
  end

  def create
    Tasks::CreateTask.call(
      household: Current.household,
      title: task_params[:title],
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
    redirect_to tasks_path, alert: "Impossible de créer la tâche."
  end

  def edit
  end

  def update
    @task.assign_attributes(
      title: task_params[:title],
      description: task_params[:description],
      emoji: task_params[:emoji],
      due_on: task_params[:due_on]
    )
    @task.assignee = find_member(task_params[:assignee_id])
    @task.task_category = find_category(task_params[:task_category_id])

    if @task.save
      redirect_to tasks_path, notice: "Tâche mise à jour."
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

  private
    def set_task
      @task = Current.household.tasks.find(params[:id])
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
