class SharedProjectParticipantsController < ApplicationController
  before_action :set_project

  def create
    participant = @project.shared_project_participants.new(participant_params)
    if participant.save
      redirect_to @project
    else
      redirect_to @project, alert: participant.errors.full_messages.to_sentence
    end
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
