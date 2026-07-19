class FeedingSessionsController < ApplicationController
  before_action :set_baby
  before_action :set_session, only: %i[edit update stop destroy]

  def create
    session = @baby.feeding_sessions.new(feeding_params)
    session.started_at ||= Time.current
    if session.save
      redirect_to @baby, notice: t(".created")
    else
      redirect_to @baby, alert: session.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @session.update(feeding_params)
      redirect_to @baby, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def stop
    if @session.update(ended_at: Time.current)
      redirect_to @baby, notice: t(".stopped")
    else
      redirect_to @baby, alert: @session.errors.full_messages.to_sentence
    end
  end

  def destroy
    @session.destroy
    redirect_to @baby, notice: t(".deleted")
  end

  private
    def set_baby
      @baby = Current.household.baby_profiles.find(params[:baby_profile_id])
    end

    def set_session
      @session = @baby.feeding_sessions.find(params[:id])
    end

    def feeding_params
      params.require(:feeding_session).permit(:kind, :started_at, :ended_at)
    end
end
