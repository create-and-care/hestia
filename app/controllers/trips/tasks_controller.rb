module Trips
  class TasksController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :set_trip
    before_action :set_task, only: %i[edit update toggle destroy]

    def create
      task = @trip.tasks.create!(task_params.merge(household: Current.household))
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append(dom_id(@trip, :tasks), partial: "trips/task", locals: { trip: @trip, task: task }) }
        format.html { redirect_to @trip }
      end
    rescue ActiveRecord::RecordInvalid
      redirect_to @trip, alert: t(".alert")
    end

    def edit
    end

    def update
      if @task.update(task_params)
        redirect_to @trip, notice: t(".updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def toggle
      Tasks::ToggleTask.call(task: @task)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@task, partial: "trips/task", locals: { trip: @trip, task: @task }) }
        format.html { redirect_to @trip }
      end
    end

    def destroy
      @task.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@task) }
        format.html { redirect_to @trip }
      end
    end

    private
      def set_trip
        @trip = Current.household.trips.find(params[:trip_id])
      end

      def set_task
        @task = @trip.tasks.find(params[:id])
      end

      def task_params
        params.require(:task).permit(:title, :emoji, :due_on)
      end
  end
end
