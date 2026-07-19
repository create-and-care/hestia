class SavingsEnvelopesController < ApplicationController
  before_action :set_envelope, only: %i[edit update destroy]

  def create
    envelope = Current.household.savings_envelopes.new(envelope_params)
    if envelope.save
      redirect_to budget_path
    else
      redirect_to budget_path, alert: envelope.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @envelope.update(envelope_params)
      redirect_to budget_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @envelope.destroy
    redirect_to budget_path, notice: t(".deleted")
  end

  private
    def set_envelope
      @envelope = Current.household.savings_envelopes.find(params[:id])
    end

    def envelope_params
      params.require(:savings_envelope).permit(:name, :recurring_deposit)
    end
end
