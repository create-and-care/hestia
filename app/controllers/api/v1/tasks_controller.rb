module Api
  module V1
    class TasksController < BaseController
      def index
        render json: paginate(Current.household.tasks.general.ordered).map { |task| serialize(task) }
      end

      def create
        task = Tasks::CreateTask.call(
          household: Current.household, title: params[:title],
          description: params[:description], due_on: params[:due_on]
        )
        render json: serialize(task), status: :created
      end

      def toggle
        task = Current.household.tasks.find(params[:id])
        Tasks::ToggleTask.call(task: task)
        render json: serialize(task)
      end

      private
        def serialize(task)
          task.as_json(only: %i[id title description emoji due_on done position]).merge(due_status: task.due_status)
        end
    end
  end
end
