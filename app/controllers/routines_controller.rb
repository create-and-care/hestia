class RoutinesController < ApplicationController
  before_action :set_routine, only: %i[edit update destroy complete]

  def index
    @lists = Current.household.routines.where.not(list_name: [ nil, "" ]).distinct.pluck(:list_name).sort
    @list = params[:list].presence
    routines = Current.household.routines.ordered.includes(:assignee)
    routines = routines.where(list_name: @list) if @list
    @routines = routines
    @routine = Current.household.routines.new
  end

  def create
    @routine = Current.household.routines.new(routine_params)
    @routine.assignee = scoped_member
    if @routine.save
      redirect_to routines_path
    else
      redirect_to routines_path, alert: @routine.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    @routine.assign_attributes(routine_params)
    @routine.assignee = scoped_member
    if @routine.save
      redirect_to routines_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @routine.destroy
    redirect_to routines_path, notice: t(".deleted")
  end

  def complete
    @routine.complete!(author: Current.user)
    redirect_to routines_path
  end

  private
    def set_routine
      @routine = Current.household.routines.find(params[:id])
    end

    def scoped_member
      id = params.dig(:routine, :assignee_id)
      Current.household.users.find_by(id: id) if id.present?
    end

    def routine_params
      params.require(:routine).permit(:name, :emoji, :description, :frequency, :interval, :list_name, :next_due_on)
    end
end
