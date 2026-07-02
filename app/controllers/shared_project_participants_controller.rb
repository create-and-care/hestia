class SharedProjectParticipantsController < ApplicationController
  before_action :set_project

  def create
    @project.shared_project_participants.create(participant_params)
    redirect_to @project
  end

  def destroy
    @project.shared_project_participants.find(params[:id]).destroy
    redirect_to @project
  end

  private
    def set_project
      @project = Current.household.shared_projects.find(params[:shared_project_id])
    end

    def participant_params
      params.require(:shared_project_participant).permit(:name)
    end
end
