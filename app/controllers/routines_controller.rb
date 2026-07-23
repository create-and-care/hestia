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
      redirect_to routines_path, alert: @routine.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    @routine.assign_attributes(routine_params)
    @routine.assignee = scoped_member
    if @routine.save
      respond_to do |format|
        format.turbo_stream { head :no_content } # closes the modal; the card updates via the real-time stream
        format.html { redirect_to routines_path, notice: t(".updated") }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @routine.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@routine) }
      format.html { redirect_to routines_path, notice: t(".deleted") }
    end
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
