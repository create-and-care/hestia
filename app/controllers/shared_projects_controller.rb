class SharedProjectsController < ApplicationController
  before_action :set_project, only: %i[show destroy]

  def index
    @projects = Current.household.shared_projects.ordered
    @project = Current.household.shared_projects.new
  end

  def show
    @participant = SharedProjectParticipant.new
    @expense = SharedExpense.new(spent_on: Date.current)
    @balances = Budget::SettleProject.call(project: @project)
    @transfers = Budget::SettleProject.transfers(project: @project)
  end

  def create
    @project = Current.household.shared_projects.new(project_params)
    if @project.save
      @project.shared_project_participants.create!(name: Current.user.name.presence || Current.user.email_address)
      redirect_to @project
    else
      @projects = Current.household.shared_projects.ordered
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to shared_projects_path, notice: t(".deleted")
  end

  private
    def set_project
      @project = Current.household.shared_projects.find(params[:id])
    end

    def project_params
      params.require(:shared_project).permit(:name)
    end
end
