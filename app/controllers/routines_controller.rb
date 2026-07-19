class RoutinesController < ApplicationController
  before_action :set_routine, only: %i[show edit update destroy complete]

  def index
    load_index_collections
    @routine = Current.household.routines.new
  end

  def show
    @completions = @routine.routine_completions.recent.includes(:author)
  end

  def create
    @routine = Current.household.routines.new(routine_params)
    @routine.assignee = scoped_member
    if @routine.save
      redirect_to routines_path
    else
      # Re-render the index (rather than redirect) so the invalid routine's
      # entered values and validation errors survive, matching #update's
      # behavior instead of silently discarding what was typed.
      load_index_collections
      render :index, status: :unprocessable_entity
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
    def load_index_collections
      @lists = Current.household.routines.where.not(list_name: [ nil, "" ]).distinct.pluck(:list_name).sort
      @list = params[:list].presence
      routines = Current.household.routines.ordered.includes(:assignee)
      routines = routines.where(list_name: @list) if @list
      @routines = routines
    end

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
