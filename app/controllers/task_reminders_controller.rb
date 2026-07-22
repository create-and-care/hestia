class TaskRemindersController < ApplicationController
  before_action :set_task

  def create
    @task.task_reminders.create(
      remind_at: reminder_params[:remind_at],
      user: recipient
    )
    redirect_to edit_task_path(@task)
  end

  def destroy
    @task.task_reminders.find(params[:id]).destroy
    redirect_to edit_task_path(@task), notice: t(".notice")
  end

  private
    def set_task
      @task = Current.household.tasks.find(params[:task_id])
    end

    # The recipient must always be a member of the current household (never an
    # id supplied as-is by the client).
    def recipient
      Current.household.users.find_by(id: reminder_params[:user_id]) || Current.user
    end

    def reminder_params
      params.require(:task_reminder).permit(:remind_at, :user_id)
    end
end
