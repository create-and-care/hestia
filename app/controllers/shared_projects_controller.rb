class SharedProjectsController < ApplicationController
  before_action :set_project, only: %i[show destroy]

  def index
    @projects = Current.household.shared_projects.ordered
  end

  def show
    @participant = SharedProjectParticipant.new
    @expense = SharedExpense.new(spent_on: Date.current)
    @balances = Budget::SettleProject.call(project: @project)
  end

  def create
    project = Current.household.shared_projects.create(project_params)
    project.shared_project_participants.create(name: Current.user.name.presence || Current.user.email_address) if project.persisted?
    redirect_to(project.persisted? ? project : shared_projects_path)
  end

  def destroy
    @project.destroy
    redirect_to shared_projects_path, notice: "Projet supprimé."
  end

  private
    def set_project
      @project = Current.household.shared_projects.find(params[:id])
    end

    def project_params
      params.require(:shared_project).permit(:name)
    end
end
